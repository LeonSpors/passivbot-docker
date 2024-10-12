#!/bin/bash

# Directory containing the log files
QUEUE_DIR="./../pbgui/opt_v7_queue"

# Check if the queue directory exists
if [ ! -d "$QUEUE_DIR" ]; then
    echo "The directory '$QUEUE_DIR' does not exist."
    exit 1
fi

# Find the most recently modified log file
latest_log_file=$(find "$QUEUE_DIR" -type f -name "*.log" -printf "%T@ %p\n" | sort -n -r | head -n 1 | awk '{print $2}')

# Check if a log file was found
if [ -z "$latest_log_file" ]; then
    echo "No log files found in the directory '$QUEUE_DIR'."
    exit 1
fi

# Tail the most recently modified log file without locking it
echo "Tailing file: $latest_log_file"
tail -f "$latest_log_file"
