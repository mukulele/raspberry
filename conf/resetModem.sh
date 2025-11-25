#!/bin/bash
LOG="/var/log/modem-reset.log"
echo "$(date) - PPP failed 3 times, attempting modem reset..." >> "$LOG"

# Find the active AT port
AT_PORT=""
for dev in /dev/ttyUSB*; do
    if [ -c "$dev" ]; then
        if echo -e "AT\r" > "$dev" && timeout 2 grep -q "OK" < "$dev"; then
            AT_PORT=$dev
            break
        fi
    fi
done

if [ -n "$AT_PORT" ]; then
    echo "$(date) - Found AT port: $AT_PORT" >> "$LOG"
    echo -e "AT+CFUN=1,1\r" > "$AT_PORT"
    sleep 5
    echo "$(date) - Modem reset sent, restarting PPP" >> "$LOG"
    systemctl restart pppd@gprs
else
    echo "$(date) - No responsive AT port found" >> "$LOG"
fi

# Optionally, restart pppd service
# sudo systemctl restart pppd@gprs
