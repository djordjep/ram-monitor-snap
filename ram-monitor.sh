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
    ram-monitor.sh [OPTIONS]
    RAM_THRESHOLD=70 ram-monitor.sh

ENVIRONMENT VARIABLES:
    RAM_THRESHOLD       RAM usage threshold percentage (default: 80)

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
threshold=${RAM_THRESHOLD:-${1:-80}}
interval=60  # Check interval in seconds (edit as needed)

echo "Monitoring RAM with threshold: $threshold%"

while true; do
    # Get used RAM percentage (Mem line from free, used/total * 100)
    used=$(free -m | awk '/Mem/ {printf "%.2f", $3/$2 * 100}')

    # Compare with threshold using awk (handles floating point correctly)
    if awk -v used="$used" -v threshold="$threshold" 'BEGIN { exit !(used > threshold) }'; then
        notify-send "High RAM Usage Alert" "Current usage: $used% (exceeds $threshold%)"
        # Optional: Add a cooldown to avoid spamming notifications
        sleep 300  # Wait 5 minutes before checking again after alert
    fi
    
    sleep $interval
done