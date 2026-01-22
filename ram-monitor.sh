#!/usr/bin/env bash

# Simple RAM monitor script for Linux.
# Usage: ./ram_monitor.sh [threshold_percentage]
# Default threshold: 80%
# Checks every 60 seconds; sends notification if used RAM exceeds threshold.

# Check for help option
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    cat << EOF
RAM Monitor - Linux RAM usage monitoring daemon

USAGE:
    ram-monitor.sh [OPTIONS] [THRESHOLD]

OPTIONS:
    -h, --help          Show this help message
    THRESHOLD           RAM usage threshold percentage (default: 80)

DESCRIPTION:
    Monitors system RAM usage continuously and sends desktop notifications
    when usage exceeds the specified threshold.

    Default threshold: 80%
    Check interval: 60 seconds
    Cooldown after alert: 5 minutes

EXAMPLES:
    ram-monitor.sh              # Monitor with default 80% threshold
    ram-monitor.sh 50           # Monitor with 50% threshold
    ram-monitor.sh --help       # Show this help message

EOF
    exit 0
fi

threshold=${1:-80}
interval=60  # Check interval in seconds (edit as needed)

echo "Monitoring RAM with threshold: $threshold%"

while true; do
    # Get used RAM percentage (Mem line from free, used/total * 100)
    used=$(free -m | awk '/Mem/ {printf "%.2f", $3/$2 * 100}')

    # Compare with threshold using simple shell arithmetic (convert to integers for comparison)
    used_int=$(printf "%.0f" "$used")
    threshold_int=$(printf "%.0f" "$threshold")
    if [ "$used_int" -gt "$threshold_int" ]; then
        notify-send "High RAM Usage Alert" "Current usage: $used% (exceeds $threshold%)"
        # Optional: Add a cooldown to avoid spamming notifications
        sleep 300  # Wait 5 minutes before checking again after alert
    fi
    
    sleep $interval
done