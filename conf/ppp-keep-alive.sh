#!/bin/bash
#
# PPP Keep Alive Script
# - Logs PPP status, bytes, uptime, failure cause
# - Restarts only after N consecutive failures
# - Sends logs to both a file and syslog

LOG_FILE="/var/log/ppp-keep-alive"
STATE_FILE="/var/run/ppp-keep-alive-fails"
IFACE="ppp0"
MAX_FAILS=3
TAG="ppp-keep-alive"

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log_msg() {
    local msg="$1"
    echo "$(timestamp) $msg" >> "$LOG_FILE"
    logger -t "$TAG" "$msg"
}

get_bytes() {
    RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null)
    TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null)
    echo "RX=${RX:-0} bytes  TX=${TX:-0} bytes"
}

get_uptime() {
    ip link show "$IFACE" 2>/dev/null | grep -q "state UP" && echo "Link is UP" || echo "Link is DOWN"
}

diagnose_failure() {
    if ! ip link show "$IFACE" &>/dev/null; then
        echo "PPP interface missing"
        return
    fi
    if ! ip link show "$IFACE" | grep -q "state UP"; then
        echo "Interface DOWN"
        return
    fi
    if ! ip addr show "$IFACE" | grep -q "inet "; then
        echo "No IP address assigned"
        return
    fi
    if ! ip route | grep -q "^default .* $IFACE"; then
        echo "No default route via $IFACE"
        return
    fi
    if ! getent hosts google.com >/dev/null; then
        echo "DNS resolution failed"
        return
    fi
    echo "Ping failed despite link, IP, route, and DNS being OK"
}

# Load current fail count
FAIL_COUNT=0
if [[ -f "$STATE_FILE" ]]; then
    FAIL_COUNT=$(<"$STATE_FILE")
fi

# Main check
if ping -I "$IFACE" -c 2 -W 3 google.com &> /dev/null; then
    BYTES=$(get_bytes)
    UPTIME=$(get_uptime)
    log_msg "ping OK | $BYTES | $UPTIME"
    FAIL_COUNT=0
else
    REASON=$(diagnose_failure)
    ((FAIL_COUNT++))
    log_msg "ping FAIL ($FAIL_COUNT/$MAX_FAILS) | Reason: $REASON"

    if (( FAIL_COUNT >= MAX_FAILS )); then
        log_msg "Restarting PPP (failures reached $MAX_FAILS)"
        pon
        FAIL_COUNT=0
    fi
fi

# Save fail count
echo "$FAIL_COUNT" > "$STATE_FILE"

