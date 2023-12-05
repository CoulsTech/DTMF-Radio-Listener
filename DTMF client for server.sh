#!/bin/bash

# Configurable Variables
frequency="<your_frequency>"
listening_delay=60
dtmf_sequence_to_listen="your_dtmf_sequence"
command_sequence_prefix="*"

# Paths
multimon_ng_path="/path/to/multimon-ng"
your_script_path="/path/to/your_script.sh"

# Log File
log_file="/path/to/log.txt"

# Functions

# Function to execute a command and log the timestamp and command
execute_command() {
    local command="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Add your logic to execute the command or kick off the Cron Job

    # Log the timestamp and executed command to the specified log file
    echo -e "$timestamp - Executing command:\n$command\n" >> "$log_file"
}

# Main Loop
while true; do
    # Continuously monitor the output for DTMF tones using multimon-ng
    output=$("$multimon_ng_path" -t raw -a DTMF -f "$frequency" -)

    # Check for the command DTMF tone (asterisk)
    if echo "$output" | grep -q "$command_sequence_prefix"; then
        # Enter listening mode and record the start time
        listening_mode=true
        start_time=$(date +%s)

        # Process the command DTMF tone
        command_sequence=$(echo "$output" | grep -oP "${command_sequence_prefix}\K\d+")
        if [ -n "$command_sequence" ]; then
            # Execute your command or kick off your Cron Job based on the command_sequence
            execute_command "$command_sequence"
        fi
    fi

    # If in listening mode, check for the specific DTMF sequence
    if [ "$listening_mode" = true ]; then
        if echo "$output" | grep -q "$dtmf_sequence_to_listen"; then
            # Execute your command or kick off your Cron Job
            execute_command "your_specific_command"
            
            # Exit listening mode
            listening_mode=false
        fi

        # Check if the specified delay has passed since entering listening mode
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ "$elapsed_time" -ge "$listening_delay" ]; then
            # Exit listening mode after the specified delay
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Ignored DTMF tones" >> "$log_file"
            listening_mode=false
        fi
    fi

    # Add a delay to control how often you check for tones
    
sleep 5
done
