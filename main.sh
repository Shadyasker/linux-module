#!/bin/bash

# Usage function to display help
usage() {
    echo "************************************************************************"
    echo "*                                                                      *"
    echo "*                          DLT LOGGER                                  *"
    echo "*                                                                      *"
    echo "************************************************************************"    
    echo "Usage: "DLT_Analyzer" [options] logfile"
    echo "Options:"
    echo "  -e            Filter for ERROR level messages"
    echo "  -w            Filter for WARN level messages"
    echo "  -i            Filter for INFO level messages"
    echo "  -d            Filter for DEBUG level messages"
    echo "  -s            Summarize errors and warnings"
    echo "  -t            Track specific events"
    echo "  -r            Generate report"
    echo "  -h            Display this help message"
}

# Function to parse logs and extract key information
parse_logs() {
    local logfile=$1
    grep -E 'ERROR|WARN|INFO|DEBUG' "$logfile" | while read -r line; do
        timestamp=$(echo "$line" | awk '{print $1, $2}')
        log_level=$(echo "$line" | awk '{print $3}')
        message=$(echo "$line" | cut -d ' ' -f 4-)
        echo "$timestamp $log_level $message"
    done
}

# Function to filter logs by level
filter_logs() {
    local logfile=$1
    local level=$2
    grep "$level" "$logfile"
}

# Function to summarize errors and warnings
summarize_logs() {
    local logfile=$1
    echo "Summary of errors and warnings:"
    grep -E 'ERROR|WARN' "$logfile" | awk '{print $3}' | sort | uniq -c | sort -nr
}

# Function to track specific events
track_events() {
    local logfile=$1
    echo "Tracking specific events:"
    grep -E 'System Startup Sequence Initiated|System health check OK' "$logfile"
}

# Function to generate a report
generate_report() {
    local logfile=$1
    local report="report.txt"
    {
        echo "DLT Log Analysis Report"
        echo "======================="
        echo ""
        echo "Log Summary:"
        summarize_logs "$logfile"
        echo ""
        echo "Specific Events:"
        track_events "$logfile"
    } > "$report"
    echo "Report generated: $report"
}



# Check if at least one argument is provided
if (( $# < 1 )); then
    usage
    exit 1
fi

# Parse command line options
while getopts "ewidstrh" option; do
    case $option in
        e)
            FILTER="ERROR"
            ;;
        w)
            FILTER="WARN"
            ;;
        i)
            FILTER="INFO"
            ;;
        d)
            FILTER="DEBUG"
            ;;
        s)
            SUMMARIZE=true
            ;;
        t)
            TRACK=true
            ;;
        r)
            REPORT=true
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

# Shift arguments to get the logfile
shift $((OPTIND - 1))
logfile=$1

# Check if the logfile exists
if [ ! -f "$logfile" ]; then
    echo "Error: Log file not found!"
    usage
    exit 1
fi

# Apply filters and actions
if [ ! -z "$FILTER" ]; then
    filter_logs "$logfile" "$FILTER"
fi

if [ "$SUMMARIZE" = true ]; then
    summarize_logs "$logfile"
fi

if [ "$TRACK" = true ]; then
    track_events "$logfile"
fi

if [ "$REPORT" = true ]; then
    generate_report "$logfile"
fi

# If no options provided, parse the logs by default
if [ -z "$FILTER" ] && [ -z "$SUMMARIZE" ] && [ -z "$TRACK" ] && [ -z "$REPORT" ]; then
    parse_logs "$logfile"
fi
