#!/usr/bin/env bash

# Simple RAM monitor script for Linux.
# Usage: ./ram_monitor.sh [threshold_percentage]
# Default threshold: 80%
# Checks every 60 seconds; sends notification if used RAM exceeds threshold.

# Check for help option
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    cat << EOF
RAM Monitor - Linux RAM usage monitor

USAGE:
    ram-monitor.sh [OPTIONS]
    RAM_THRESHOLD=70 ram-monitor.sh

ENVIRONMENT VARIABLES:
    RAM_THRESHOLD       RAM usage threshold percentage (default: 80)
    RAM_INTERVAL        Polling interval in seconds (default: 60)
    RAM_COOLDOWN        Alert cooldown in seconds (default: 300)

OPTIONS:
    -h, --help          Show this help message

DESCRIPTION:
    Monitors system RAM usage continuously and sends desktop notifications
    when usage exceeds the specified threshold.

    RAM calculation: Physical memory only (may differ from system monitors)
    Default threshold: 80%
    Check interval: 60 seconds
    Cooldown after alert: 5 minutes

EXAMPLES:
    ram-monitor.sh                    # Monitor with default 80% threshold
    RAM_THRESHOLD=70 ram-monitor.sh   # Monitor with 70% threshold
    ram-monitor.sh --help            # Show this help message

CONFIGURATION:
    Use RAM_THRESHOLD environment variable to customize threshold.
    For persistent settings, add to your shell profile:
    echo 'export RAM_THRESHOLD=75' >> ~/.bashrc && source ~/.bashrc

EOF
    exit 0
fi

# Priority: Environment Variable > Command Line Arg > Default
threshold="${RAM_THRESHOLD:-${1:-80}}"
interval="${RAM_INTERVAL:-60}"
cooldown="${RAM_COOLDOWN:-300}"
last_alert_at=0

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ram-monitor] $*"
}

validate_number() {
    awk -v value="$1" 'BEGIN { exit !(value ~ /^[0-9]+(\.[0-9]+)?$/) }'
}

validate_integer() {
    awk -v value="$1" 'BEGIN { exit !(value ~ /^[0-9]+$/) }'
}

if ! validate_number "$threshold"; then
    log "Invalid RAM threshold: '$threshold' (must be numeric)."
    exit 1
fi

if ! validate_integer "$interval"; then
    log "Invalid RAM interval: '$interval' (must be an integer)."
    exit 1
fi

if ! validate_integer "$cooldown"; then
    log "Invalid RAM cooldown: '$cooldown' (must be an integer)."
    exit 1
fi

# Avoid duplicate loops when autostart and manual execution overlap.
# Prefer user-writable paths over system locations.
lock_root="${XDG_RUNTIME_DIR:-${HOME:-/tmp}}"
mkdir -p "$lock_root"
lock_dir="${lock_root}/ram-monitor.lock"
lock_pid_file="${lock_dir}/pid"

if mkdir "$lock_dir" 2>/dev/null; then
    echo "$$" > "$lock_pid_file"
else
    existing_pid=""
    if [ -f "$lock_pid_file" ]; then
        existing_pid="$(cat "$lock_pid_file" 2>/dev/null || true)"
    fi

    if [ -n "$existing_pid" ]; then
        if kill -0 "$existing_pid" 2>/dev/null || [ -d "/proc/$existing_pid" ]; then
            log "Another instance is already running (pid: $existing_pid); exiting."
            exit 0
        fi
    fi

    log "Removing stale lock and continuing."
    rm -rf "$lock_dir" 2>/dev/null || true
    if mkdir "$lock_dir" 2>/dev/null; then
        echo "$$" > "$lock_pid_file"
    else
        log "Failed to acquire instance lock at '$lock_dir'; exiting."
        exit 1
    fi
fi
trap 'rm -f "$lock_pid_file"; rmdir "$lock_dir" 2>/dev/null || true' EXIT

log "Monitoring RAM with threshold: $threshold%, interval: ${interval}s, cooldown: ${cooldown}s"

while true; do
    # Get used RAM percentage (Mem line from free, used/total * 100)
    used="$(free -m | awk '/Mem/ {printf "%.2f", $3/$2 * 100}')"
    now="$(date +%s)"

    # Compare with threshold using awk (handles floating point correctly)
    if awk -v used="$used" -v threshold="$threshold" 'BEGIN { exit !(used > threshold) }'; then
        seconds_since_last=$((now - last_alert_at))
        if [ "$seconds_since_last" -ge "$cooldown" ]; then
            if notify-send --app-name="RAM Monitor" --urgency=critical \
                "High RAM Usage Alert" "Current usage: $used% (exceeds $threshold%)"; then
                log "Alert sent: RAM usage $used% exceeded threshold $threshold%"
                last_alert_at="$now"
            else
                log "notify-send failed (DISPLAY='${DISPLAY:-unset}', DBUS_SESSION_BUS_ADDRESS='${DBUS_SESSION_BUS_ADDRESS:-unset}')."
            fi
        fi
    fi

    sleep "$interval"
done