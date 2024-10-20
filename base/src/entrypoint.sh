#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
CONTAINER_DATA=$HOME/.container
PB6_VERSION=${PB6_VERSION:-v6.1.4b}   # Default version for PB6
PB7_VERSION=master   # Default version for PB7
PBGUI_VERSION=${PBGUI_VERSION:-main}    # Default version for PBGUI

mkdir -p $CONTAINER_DATA

# Change to the directory where the repositories will be cloned
cd /app || { echo "Failed to change directory to /app"; exit 1; }


# Function to clone repository
clone_repo() {
    local dir_name=$1
    local repo_url=$2
    local branch=$3 

    echo "Branch: $branch"

    # Check if the target directory contains a .git folder
    if [ -d "$dir_name/.git" ]; then
        return
    fi

    # Clone the repository into a temporary directory
    local temp_clone=$(mktemp -d "/tmp/${dir_name}.XXXXXX")
    echo "Cloning repository from $repo_url to temporary directory $temp_clone..."
    git clone -b "$branch" "$repo_url" "$temp_clone" || { echo "Failed to clone repository: $repo_url"; exit 1; }

    # Create the target directory if it doesn't exist
    mkdir -p "$dir_name"

    # Move files from the temporary clone to the target directory without overwriting
    echo "Moving new files from $temp_clone to $dir_name..."
    for file in "$temp_clone/"* "$temp_clone"/.*; do
        # Check if the file is not the current directory (.) or parent directory (..)
        if [[ "$file" != "$temp_clone/." && "$file" != "$temp_clone/.." ]]; then
            local base_file=$(basename "$file")
            if [ ! -e "$dir_name/$base_file" ]; then
                mv "$file" "$dir_name/" || { echo "Failed to move $file to $dir_name"; exit 1; }
                echo "Moved $base_file to $dir_name."
            else
                echo "$base_file already exists in $dir_name. Skipping."
            fi
        fi
    done


    # Clean up the temporary clone
    rm -rf "$temp_clone"
    echo "Cleaned up temporary directory $temp_clone."
    FORCE_INSTALL=true
}

# Function to install
install () {
    local app_dir=$1
    local venv_dir=$2
    local requirements_file="$app_dir/requirements.txt"
    local commit_file="$CONTAINER_DATA/$(basename "$app_dir")_installed_commit.txt"

    echo "App dir: $app_dir"
    echo "Venv dir: $venv_dir"

    # Change to the application directory
    cd "$app_dir" || exit

    # Fetch the latest changes from the remote
    git fetch --all -q

    # Get the current branch name and check if we're on a tag
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    local is_tag=$(git describe --tags --exact-match 2>/dev/null)

    # Get the current and remote commit hashes
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse @{u} 2>/dev/null || echo "")

    # Determine if FORCE_INSTALL should be set to true
    if [ "$FORCE_INSTALL" != true ]; then
        # First installation if commit file does not exist
        if [ ! -f "$commit_file" ]; then
            FORCE_INSTALL=true
            echo "Initial installation for $app_dir detected. Setting FORCE_INSTALL to true."
        # If the current commit is already installed, skip installation
        elif [ "$(cat "$commit_file")" = "$local_commit" ]; then
            echo "Current commit is already installed for $app_dir. Skipping installation."
            cd - || exit
            return
        # If on main/master and tagged commit is up to date, skip installation
        elif [ -n "$is_tag" ] && [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
            if [ "$local_commit" = "$remote_commit" ]; then
                echo "Current commit is tagged and up-to-date with $current_branch branch. Skipping installation."
                cd - || exit
                return
            fi
        # If in a detached HEAD state, skip installation
        elif [ "$current_branch" = "HEAD" ]; then
            echo "Detached HEAD state. Skipping remote tracking check."
            cd - || exit
            return
        # If there is no remote tracking branch, skip installation
        elif [ -z "$remote_commit" ]; then
            echo "No remote tracking branch found. Skipping requirements installation."
            cd - || exit
            return
        # If there are changes that can be fetched, enable FORCE_INSTALL
        elif [ "$local_commit" != "$remote_commit" ]; then
            echo "Fetching latest commit..."
            git pull -q

            echo "Changes detected in $app_dir. Setting FORCE_INSTALL to true..."
            FORCE_INSTALL=true
        fi
    fi

    # If FORCE_INSTALL is true, proceed with installation
    if [ "$FORCE_INSTALL" = true ]; then
        echo "Proceeding with installation for $app_dir..."

        # Activate the virtual environment
        source "$venv_dir/bin/activate"
        pip install -q --upgrade pip  # Upgrade pip
        pip install -q -r "$requirements_file"  # Install requirements

        # If installing for pb7, build the Rust components
        if [[ "$app_dir" == "/app/pb7" ]]; then
            echo "Building Rust components for pb7..."
            cd passivbot-rust
            maturin develop --release > /dev/null 2>&1 # Build Rust components
            cd - || exit
        fi

        deactivate

        # Save the current commit hash to the file after a successful installation
        echo "$local_commit" > "$commit_file"
    fi

    cd - || exit
}

# Clone repositories
clone_repo "pb6" "https://github.com/enarjord/passivbot.git" "$PB6_VERSION"
clone_repo "pb7" "https://github.com/enarjord/passivbot.git" "$PB7_VERSION"
clone_repo "pbgui" "https://github.com/msei99/pbgui.git" "$PBGUI_VERSION"

# Install dependencies for each app
install "/app/pb6" "/venv_pb6"
install "/app/pb7" "/venv_pb7"
install "/app/pbgui" "/venv_pbgui"

# Set workspace
cd /app/pbgui/

# Activate the virtual environment for PBGUI
source /venv_pbgui/bin/activate

# Run the Streamlit app
exec streamlit run ./pbgui.py --server.port=8501 --server.address=0.0.0.0