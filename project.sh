#!/usr/bin/bash -i

# Source the configuration file
source ./process_monitor.conf

# Function to list all running processes
list_all_processes() {
    echo "Listing all running processes:"
    ps -eo pid,ppid,uid,cmd,%mem,%cpu --sort=-%mem | head -n 20
}

# Function to get detailed information about a specific process
process_info() {
    read -p "Enter the PID of the process: " pid
    ps -p $pid -o pid,ppid,uid,user,cmd,%mem,%cpu,etime
}

# Function to kill a specific process
kill_process() {
    read -p "Enter the PID of the process to kill: " pid
    kill -9 $pid
    echo "Process $pid has been killed."
}

# Function to display system process statistics
process_statistics() {
    echo "Total number of processes: $(ps -e | wc -l)"
    echo "Memory usage: $(free -m | grep Mem | awk '{print $3 "MB / " $2 "MB"}')"
    echo "CPU load: $(uptime | awk -F 'load average: ' '{print $2}')"
}

# Function to implement real-time monitoring
real_time_monitoring() {
    while true; do
        clear
        list_all_processes
        sleep $UPDATE_INTERVAL
    done
}

# Function to search for processes
search_processes() {
    read -p "Enter the search term (name/user/resource usage): " term
    ps -eo pid,ppid,uid,user,cmd,%mem,%cpu --sort=-%mem | grep $term
}

# Function to handle resource usage alerts
resource_usage_alerts() {
    while true; do
        high_cpu=$(ps -eo pid,cmd,%cpu --sort=-%cpu | awk -v threshold=$CPU_ALERT_THRESHOLD '$3 > threshold {print $1, $2, $3}')
        high_mem=$(ps -eo pid,cmd,%mem --sort=-%mem | awk -v threshold=$MEMORY_ALERT_THRESHOLD '$3 > threshold {print $1, $2, $3}')
        
        if [ ! -z "$high_cpu" ]; then
            echo "High CPU usage detected:"
            echo "$high_cpu"
        fi

        if [ ! -z "$high_mem" ]; then
            echo "High Memory usage detected:"
            echo "$high_mem"
        fi

        sleep $UPDATE_INTERVAL
    done
}

# Function to display the interactive menu
interactive_menu() {
    while true; do
        echo "Process Monitor Menu:"
        echo "1. List running processes"
        echo "2. Get process information"
        echo "3. Kill a process"
        echo "4. Display process statistics"
        echo "5. Real-time monitoring"
        echo "6. Search processes"
        echo "7. Exit"
        read -p "Choose an option: " option

        case $option in
            1) list_all_processes ;;
            2) process_info ;;
            3) kill_process ;;
            4) process_statistics ;;
            5) real_time_monitoring ;;
            6) search_processes ;;
            7) exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

# Main script execution
interactive_menu
