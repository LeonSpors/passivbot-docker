#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
CONTAINER_DATA=$HOME/.container
PBG6_VERSION=${PBG6_VERSION:-v6.1.4b}   # Default version for PB6
PBG7_VERSION=${PBG7_VERSION:-master}    # Default version for PB7
PBGUI_VERSION=${PBGUI_VERSION:-main}    # Default version for PBGUI

mkdir -p $CONTAINER_DATA

# Change to the directory where the repositories will be cloned
cd /app || exit

# Clone repositories if they don't exist
if [ ! -d "pbgui" ]; then
    git clone https://github.com/msei99/pbgui.git
    echo "Cloned pbgui repository."
    FORCE_INSTALL=true
fi

if [ ! -d "pb6" ]; then
    git clone https://github.com/enarjord/passivbot.git pb6
    echo "Cloned pb6 repository."
    FORCE_INSTALL=true
fi

if [ ! -d "pb7" ]; then
    git clone https://github.com/enarjord/passivbot.git pb7
    echo "Cloned pb7 repository."
    FORCE_INSTALL=true
fi

# Function to install
install() {
    local app_dir=$1
    local venv_dir=$2
    local requirements_file="$app_dir/requirements.txt"
    local commit_file="$CONTAINER_DATA/$(basename "$app_dir")_installed_commit.txt"

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


# Checkout specific versions
cd pb6
git checkout "$PBG6_VERSION" -q || { echo "Failed to checkout $PBG6_VERSION in pb6"; exit 1; }
cd ..

cd pb7
git checkout "$PBG7_VERSION" -q || { echo "Failed to checkout $PBG7_VERSION in pb7"; exit 1; }
cd ..

cd pbgui
git checkout "$PBGUI_VERSION" -q || { echo "Failed to checkout $PBGUI_VERSION in pbgui"; exit 1; }
cd ..

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