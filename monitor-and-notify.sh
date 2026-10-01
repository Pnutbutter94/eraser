#!/bin/bash
set -euo pipefail
cd /opt/eraser

send_telegram() {
    /opt/casaserver/scripts/send-telegram.sh "$1"
}

./eraser monitor --once >> /opt/eraser/monitor.log 2>&1
./eraser confirm --pending >> /opt/eraser/monitor.log 2>&1
./eraser fill --pending --submit --config /root/.eraser/config.yaml >> /opt/eraser/monitor.log 2>&1 || true

PIPELINE=$(./eraser pipeline 2>/dev/null)

form=$(echo "$PIPELINE" | grep "Form required" | grep -o '[0-9]*' | tail -1)
captcha=$(echo "$PIPELINE" | grep "CAPTCHA" | grep -o '[0-9]*' | tail -1)
confirm=$(echo "$PIPELINE" | grep "Awaiting confirmation" | grep -o '[0-9]*' | tail -1)

form=${form:-0}
captcha=${captcha:-0}
confirm=${confirm:-0}

total=$((form + captcha + confirm))

if [ "$total" -gt 0 ]; then
    send_telegram "🔒 Eraser — Action Needed: $total broker(s) require manual action (forms=$form, captchas=$captcha, confirmations=$confirm). Open http://100.100.203.28:8888 to handle."
fi
