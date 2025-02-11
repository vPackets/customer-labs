#!/bin/bash

# Ping Generator Script
# Designed to run continuously with configurable options

# Default configuration
TARGETS=("1.1.1.1" "2.2.2.2" "3.3.3.3"  "5.5.5.5" "6.6.6.6" "7.7.7.7")  # Default targets if none provided
INTERVAL=1  # Default ping interval (seconds)
PACKET_SIZE=56  # Default ICMP packet size
LOG_FILE="/var/log/ping_generator.log"

# Parse command-line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--targets)
                # Split comma-separated targets into array
                IFS=',' read -r -a TARGETS <<< "$2"
                shift 2
                ;;
            -i|--interval)
                INTERVAL="$2"
                shift 2
                ;;
            -s|--size)
                PACKET_SIZE="$2"
                shift 2
                ;;
            -l|--log)
                LOG_FILE="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Help information
show_help() {
    echo "Continuous Ping Generator"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -t, --targets   Comma-separated list of IP targets (default: 8.8.8.8,1.1.1.1)"
    echo "  -i, --interval  Ping interval in seconds (default: 1)"
    echo "  -s, --size      ICMP packet size in bytes (default: 56)"
    echo "  -l, --log       Log file path (default: /var/log/ping_generator.log)"
    echo "  -h, --help      Show this help message"
}

# Ping function with logging
ping_target() {
    local target="$1"
    local log_file="$2"
    local interval="$3"
    local packet_size="$4"

    # Redirect both stdout and stderr to log file
    while true; do
        # Use printf for precise timestamp
        printf "[%(%Y-%m-%d %H:%M:%S)T] Pinging $target with $packet_size bytes\n" -1 >> "$log_file"
        
        # Ping with specified packet size, continuous mode
        ping -c 1 -s "$packet_size" "$target" | while read -r line; do
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line" >> "$log_file"
        done

        # Sleep between pings to control interval
        sleep "$interval"
    done
}

# Trap signals for graceful shutdown
trap_signals() {
    echo "Received shutdown signal. Stopping ping generator..."
    # Perform cleanup if needed
    exit 0
}

# Main execution
main() {
    # Parse any command-line arguments
    parse_arguments "$@"

    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"

    # Trap signals
    trap trap_signals SIGINT SIGTERM

    # Start pings to multiple targets in parallel
    for target in "${TARGETS[@]}"; do
        ping_target "$target" "$LOG_FILE" "$INTERVAL" "$PACKET_SIZE" &
    done

    # Wait for all background processes
    wait
}

# Run the main function
main "$@"