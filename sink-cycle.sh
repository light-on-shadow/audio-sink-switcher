#!/bin/bash

# Configuration file to store desired sinks
config_file="$HOME/.config/audio_sink_switcher.conf"

# Function to prompt user to select desired sinks
select_desired_sinks() {
    # Get the list of available sinks, remove any trailing newline, and ignore empty lines
    available_sinks=$(pactl list short sinks | awk '{print $2}' )

    # Check if any sinks are available
    if [ -z "$available_sinks" ]; then
        zenity --error --text="No audio sinks are available. Exiting."
        exit 1
    fi

    # Prepare the available sinks list for zenity --checklist (format: SinkName FALSE)
    sinks_for_zenity=$(echo "$available_sinks" | awk '{print "FALSE", $1}')

    # Use zenity to allow multiple selections with checkboxes
    selected_sinks=$(zenity --list --checklist \
    --title="Select Audio Sinks" \
    --width=600 \
    --height=600 \
    --column="Select" --column="Sink Name" \
    $sinks_for_zenity \
    --separator=":")

    # Check if zenity returned a valid selection
    if [ -z "$selected_sinks" ]; then
        exit 1
    fi

    # Convert selected sinks into an array
    IFS=':' read -r -a desired_sinks <<< "$selected_sinks"
    
    # Save desired_sinks to config file
    mkdir -p "$(dirname "$config_file")"
    echo "desired_sinks=(${desired_sinks[@]})" > "$config_file"
}

# Load desired_sinks from config file if it exists
if [ -f "$config_file" ]; then
    source "$config_file"
else
    # No config file found or user wants to reselect sinks
    select_desired_sinks
fi

# Get the list of available sinks
available_sinks=$(pactl list short sinks | awk '{print $2}' | sed '/^$/d')

# Filter desired_sinks to only include available sinks
filtered_sinks=()
for sink in "${desired_sinks[@]}"; do
    if echo "$available_sinks" | grep -q "^$sink$"; then
        filtered_sinks+=("$sink")
    else
        # Sink not available, inform user
        zenity --warning --text="Sink '$sink' not found and will be removed from your desired sinks."
    fi
done

# Update config file with filtered sinks
if [ ${#filtered_sinks[@]} -ne ${#desired_sinks[@]} ]; then
    desired_sinks=(${filtered_sinks[@]})
    echo "desired_sinks=(${desired_sinks[@]})" > "$config_file"
fi

# If filtered_sinks is empty, prompt user to select new desired sinks
if [ ${#filtered_sinks[@]} -eq 0 ]; then
    zenity --info --text="No desired sinks are currently available. Please select available sinks."
    select_desired_sinks
    filtered_sinks=(${desired_sinks[@]})
fi

# Get the current default sink
current_sink=$(pactl info | grep "Default Sink" | awk '{print $3}')

# Find the index of the current sink in the filtered_sinks array
current_index=-1
for i in "${!filtered_sinks[@]}"; do
    if [[ "${filtered_sinks[$i]}" == "$current_sink" ]]; then
        current_index=$i
        break
    fi
done

# Calculate the next index
next_index=$(( (current_index + 1) % ${#filtered_sinks[@]} ))

# Get the next sink name
next_sink=${filtered_sinks[$next_index]}

# Set the default sink to the next sink
pactl set-default-sink "$next_sink"

# Move all currently playing streams to the new sink
# Get a list of sink inputs
sink_inputs=$(pactl list short sink-inputs | awk '{print $1}')
for input in $sink_inputs; do
    pactl move-sink-input "$input" "$next_sink"
done

# Notify the user
zenity --notification --text="Default sink set to: $next_sink"

echo "Default sink set to: $next_sink"

