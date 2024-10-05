#!/bin/bash

# Save the current directory
CURRENT_DIR=$(pwd)

# Change to the parent directory
cd ..

# Set USERDATA
USERDATA=$(pwd)

# Return to the original directory
cd "$CURRENT_DIR"

# Ask for user confirmation
read -p "Do you want to create the folder and files under this location? $USERDATA (y/n): " CONFIRM
if [[ "$CONFIRM" != [yY] ]]; then
    echo "Operation canceled."
    exit 1
fi

# Create the necessary directory structure
mkdir -p "$USERDATA/configs"
mkdir -p "$USERDATA/historical_data"
mkdir -p "$USERDATA/pb6/backtests"
mkdir -p "$USERDATA/pb6/caches"
mkdir -p "$USERDATA/pb6/configs"
mkdir -p "$USERDATA/pb6/optimize_results"
mkdir -p "$USERDATA/pb6/optimize_results_analysis"
mkdir -p "$USERDATA/pb7/backtests"
mkdir -p "$USERDATA/pb7/caches"
mkdir -p "$USERDATA/pb7/configs"
mkdir -p "$USERDATA/pb7/optimize_results"
mkdir -p "$USERDATA/pb7/optimize_results_analysis"
mkdir -p "$USERDATA/pbgui"

echo "Folder structure created successfully."

# Create secrets.toml if it doesn't exist
if [[ ! -e "$USERDATA/configs/secrets.toml" ]]; then
    echo 'password = "your-password"' > "$USERDATA/configs/secrets.toml"
    echo "secrets.toml created."
else
    echo "secrets.toml already exists."
fi

# Create api-keys.json if it doesn't exist
if [[ ! -e "$USERDATA/configs/api-keys.json" ]]; then
    echo '{}' > "$USERDATA/configs/api-keys.json"
    echo "api-keys.json created."
else
    echo "api-keys.json already exists."
fi

# Create pbgui.ini if it doesn't exist
if [[ ! -e "$USERDATA/configs/pbgui.ini" ]]; then
    cat <<EOL > "$USERDATA/configs/pbgui.ini"
[main]
pbdir = /app/pb6
pbvenv = /venv_pb6/bin/python
pb7dir = /app/pb7
pb7venv = /venv_pb7/bin/python
pbname = docker
EOL
    echo "pbgui.ini created."
else
    echo "pbgui.ini already exists."
fi

echo "File creation check completed in $USERDATA directory."