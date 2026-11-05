#!/usr/bin/env bash
set -euo pipefail

mkdir -p diagnostics
APK="build/app/outputs/flutter-apk/app-release.apk"
PACKAGE_ID="com.awasigogera.wapari"

# Fail clearly if the APK path is wrong before asking ADB to install it.
test -s "$APK"
adb wait-for-device
adb install -r "$APK"
adb logcat -c
adb shell monkey -p "$PACKAGE_ID" -c android.intent.category.LAUNCHER 1
sleep 15

# Capture crash and main buffers, then restrict inspection to the Wapari
# process. Android system services (for example droid.bluetooth) can emit
# unrelated SIGABRT entries in the emulator crash buffer.
adb logcat -b crash -d -v threadtime > /tmp/wapari-crash-buffer.txt
adb logcat -b main -d -v threadtime > /tmp/wapari-main-buffer.txt

# Prefer the live app PID. If the app exited quickly, recover its PID from
# AndroidRuntime's "Process: <package>, PID: ..." exception header.
APP_PID="$(adb shell pidof "$PACKAGE_ID" | tr -d '\r' | awk '{print $1}')"
if [ -z "$APP_PID" ]; then
  APP_PID="$(sed -n "s/.*Process: $PACKAGE_ID, PID: *\\([0-9][0-9]*\\).*/\\1/p" /tmp/wapari-main-buffer.txt | head -n 1)"
fi

: > /tmp/wapari-app-logs.txt
if [ -n "$APP_PID" ]; then
  awk -v pid="$APP_PID" '$3 == pid' /tmp/wapari-crash-buffer.txt /tmp/wapari-main-buffer.txt > /tmp/wapari-app-logs.txt
else
  # No PID was recoverable. Keep only explicit package-specific records;
  # never fail because an unrelated emulator service crashed.
  grep -F "$PACKAGE_ID" /tmp/wapari-crash-buffer.txt /tmp/wapari-main-buffer.txt > /tmp/wapari-app-logs.txt || true
fi

if grep -E -i "FATAL EXCEPTION|Fatal signal [0-9]+|Unhandled Exception|Exception caught by widgets library|E/flutter|am_crash|Process: $PACKAGE_ID|backtrace:|Failed to create an instance of androidx\.work\.impl\.WorkDatabase|SQLiteException" /tmp/wapari-app-logs.txt >/dev/null; then
  cp /tmp/wapari-app-logs.txt diagnostics/fatal-crash-logs.txt
  echo "::error::Fatal Wapari app error detected. Only app-process logs are included in the artifact."
  exit 1
fi

if ! adb shell pidof "$PACKAGE_ID" >/dev/null; then
  cp /tmp/wapari-app-logs.txt diagnostics/fatal-crash-logs.txt
  echo "::error::Wapari process is not running after launch, but no app-specific fatal marker was captured."
  exit 1
fi
echo "Wapari remained running; no fatal crash entry for the app process was found."
