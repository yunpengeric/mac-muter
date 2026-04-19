#!/bin/sh

set -eu

echo
echo "+-------------------------------------------------------------------+"
echo "| Mac Muter                                                         |"
echo "|                                                                   |"
echo "+-------------------------------------------------------------------+"
echo

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
INSTALL_DIR="${HOME}/.mac-muter"
PLIST_DIR="${HOME}/Library/LaunchAgents"
PLIST_PATH="${PLIST_DIR}/com.yunpengeric.mac-muter.plist"
LOG_DIR="${INSTALL_DIR}/logs"
BINARY_PATH="${INSTALL_DIR}/mac-muter"
LABEL="com.yunpengeric.mac-muter"

printf "What time do you want to mute (HH:MM format | 24 hour system)? "
IFS= read -r time

case "$time" in
  [0-1][0-9]:[0-5][0-9]|2[0-3]:[0-5][0-9]) ;;
  *)
    echo "Invalid time. Please use HH:MM in 24-hour format, for example 22:00."
    exit 1
    ;;
esac

H=${time%:*}
M=${time#*:}
H_INT=$((10#$H))
M_INT=$((10#$M))

mkdir -p "$INSTALL_DIR" "$PLIST_DIR" "$LOG_DIR"

cp "$SCRIPT_DIR/mute.swift" "$INSTALL_DIR/mute.swift"
MODULE_CACHE_DIR="${INSTALL_DIR}/.build/module-cache"
mkdir -p "$MODULE_CACHE_DIR"
/usr/bin/swiftc -module-cache-path "$MODULE_CACHE_DIR" "$INSTALL_DIR/mute.swift" -o "$BINARY_PATH"
chmod 755 "$BINARY_PATH"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>${BINARY_PATH}</string>
  </array>
  <key>RunAtLoad</key>
  <false/>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>${H_INT}</integer>
    <key>Minute</key>
    <integer>${M_INT}</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>${LOG_DIR}/stdout.log</string>
  <key>StandardErrorPath</key>
  <string>${LOG_DIR}/stderr.log</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)" "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"

if command -v crontab >/dev/null 2>&1; then
  TMP_CRON=$(mktemp)
  crontab -l 2>/dev/null | grep -v 'mac-muter\.applescript' > "$TMP_CRON" || true
  crontab "$TMP_CRON"
  rm -f "$TMP_CRON"
fi

echo "Done! Your computer will be muted at $time every day."
echo "Installed LaunchAgent: $PLIST_PATH"
