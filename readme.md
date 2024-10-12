# Audio Sink Switcher

## Overview

**Audio Sink Switcher** is a Bash script designed to allow users to easily manage and switch between audio output devices ("sinks") on Linux systems that use `pulseaudio`. It utilizes `zenity` for a graphical user interface to select the available sinks and save preferences for future use.

Key features include:
- Interactive checklist to select desired audio sinks.
- Saving preferred sinks for quick access in future sessions.
- Automatic cycling through available sinks.
- Moving active audio streams to the newly selected default sink.

## Prerequisites

Before using the **Audio Sink Switcher**, you need the following installed on your system:

- **PulseAudio**: For managing audio sinks. It is commonly pre-installed on most Linux distributions.
- **Zenity**: A tool that provides GTK dialog boxes from the command line.

To install Zenity, run:
```bash
sudo apt install zenity  # For Debian/Ubuntu systems
```
For Fedora-based systems:
```bash
sudo dnf install zenity
```

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/audio-sink-switcher.git
   ```

2. **Navigate to the Directory**:
   ```bash
   cd audio-sink-switcher
   ```

3. **Make the Script Executable**:
   ```bash
   chmod +x audio_sink_switcher.sh
   ```

## Usage

To run the script, simply execute:
```bash
./audio_sink_switcher.sh
```

The script will:
- Display a checklist of available audio sinks for you to choose from.
- Save your preferences to a configuration file located at `~/.config/audio_sink_switcher.conf`.
- Cycle through your preferred sinks and set the next sink as the default.
- Move all currently playing audio streams to the newly selected default sink.

## Configuration

- **Configuration File**: The script stores the preferred sinks in `~/.config/audio_sink_switcher.conf`. You can edit this file manually if needed or use the script to reselect sinks.

- **Changing Preferences**: If you need to change your sink preferences, delete the configuration file and rerun the script:
  ```bash
  rm ~/.config/audio_sink_switcher.conf
  ./audio_sink_switcher.sh
  ```

## Troubleshooting

- **No Audio Sinks Available**: If Zenity displays "No audio sinks are available", ensure that your audio hardware is correctly recognized by PulseAudio and that `pactl list short sinks` returns a list of sinks.

- **Dependencies Not Found**: Make sure that PulseAudio and Zenity are properly installed and available in your system's PATH.

