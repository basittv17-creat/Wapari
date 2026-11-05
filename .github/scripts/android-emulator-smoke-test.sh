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

# Save the complete Android crash buffer. It contains only crash records,
# including nested "Caused by" lines that the old marker-only filter omitted.
adb logcat -b crash -d -v threadtime > /tmp/wapari-crash-buffer.txt

# Also capture a bounded context around fatal/WorkManager/Room/SQLite entries
# from the main buffer, rather than uploading general device logs.
adb logcat -b main -d -v threadtime > /tmp/wapari-main-buffer.txt
grep -E -i -A 100 -B 5 "FATAL EXCEPTION|Fatal signal [0-9]+|WorkDatabase|SQLiteException|androidx\.room|Unhandled Exception|Exception caught by widgets library|E/flutter|am_crash|backtrace:" /tmp/wapari-main-buffer.txt > /tmp/wapari-relevant-main.txt || true
cat /tmp/wapari-crash-buffer.txt /tmp/wapari-relevant-main.txt > /tmp/wapari-fatal-only.txt

if grep -E -i "FATAL EXCEPTION|Fatal signal [0-9]+|Unhandled Exception|Exception caught by widgets library|E/flutter|am_crash|Process: .*, PID:|backtrace:|Failed to create an instance of androidx\.work\.impl\.WorkDatabase" /tmp/wapari-fatal-only.txt >/dev/null; then
  cp /tmp/wapari-fatal-only.txt diagnostics/fatal-crash-logs.txt
  echo "::error::Fatal app error detected. Crash buffer and bounded exception context are included in the artifact."
  exit 1
fi

if ! adb shell pidof "$PACKAGE_ID" >/dev/null; then
  cp /tmp/wapari-fatal-only.txt diagnostics/fatal-crash-logs.txt
  echo "::error::Wapari process is not running after launch, but no fatal marker was captured."
  exit 1
fi
echo "Wapari remained running; no fatal crash entry was found."
