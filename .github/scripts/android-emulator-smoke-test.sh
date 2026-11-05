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

# Keep only crash-buffer output and fatal Flutter/Android markers.
# General logcat, routine warnings, screenshots and device data are never uploaded.
adb logcat -b crash -d -v threadtime > /tmp/wapari-crash-buffer.txt
adb logcat -b main -d -v threadtime | grep -E -i "FATAL EXCEPTION|Fatal signal [0-9]+|Unhandled Exception|Exception caught by widgets library|E/flutter|am_crash|Process: .*, PID:|backtrace:" > /tmp/wapari-fatal-main-lines.txt || true
cat /tmp/wapari-crash-buffer.txt /tmp/wapari-fatal-main-lines.txt > /tmp/wapari-fatal-only.txt

if grep -E -i "FATAL EXCEPTION|Fatal signal [0-9]+|Unhandled Exception|Exception caught by widgets library|E/flutter|am_crash|Process: .*, PID:|backtrace:" /tmp/wapari-fatal-only.txt >/dev/null; then
  cp /tmp/wapari-fatal-only.txt diagnostics/fatal-crash-logs.txt
  echo "::error::Fatal app error detected. Only filtered fatal entries are included in the artifact."
  exit 1
fi

if ! adb shell pidof "$PACKAGE_ID" >/dev/null; then
  echo "::error::Wapari process is not running after launch, but no fatal marker was captured."
  exit 1
fi
echo "Wapari remained running; no fatal crash entry was found."
