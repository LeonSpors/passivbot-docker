## Dockerized Passivbot with pbgui

This Docker image provides a streamlined environment for running the Passivbot trading bot along with its graphical user interface, pbgui. Based on the lightweight `python:3.10-slim-buster` image, it includes all the necessary dependencies and setups for a hassle-free deployment.

### Features

- **Base Image**: Built on `python:3.10-slim-buster`, ensuring a minimal and efficient footprint.
- **Dependency Installation**: Installs essential tools such as Git, build-essential, Curl, and Rclone.
- **Rust & Cargo**: Automatically installs the latest version of Rust and Cargo, enabling you to compile Rust projects.
- **Repository Cloning**: Clones the required repositories for Passivbot and pbgui directly from GitHub.
- **Virtual Environments**: Sets up isolated Python environments for each component (`pb6`, `pb7`, and `pbgui`), ensuring clean installations without conflicts.
- **Dependency Management**: Installs all necessary Python packages from the requirements files for `pb6`, `pb7`, and `pbgui`.
- **Port Exposure**: Exposes port 8501 for easy access to the Streamlit application.
- **Default Command**: Runs the pbgui using Streamlit, ready for interaction on startup.

### Quick start
1. **Configure .env file**
   

   ```bash
    MOUNT_DIR=D:\pb_userdata
   ```
<br/>

2. **Create Folder Structure for Persistent Storage**

    Set up the following directory structure based on your docker-compose.yml file:

   ```bash
    pb_userdata
    ├── configs
    ├── historical_data
    ├── pb6
    │   ├── backtests
    │   ├── caches
    │   ├── configs
    │   ├── optimize_results
    │   └── optimize_results_analysis
    ├── pb7
    │   ├── backtests
    │   ├── caches
    │   ├── configs
    │   ├── optimize_results
    │   └── optimize_results_analysis
    └── pbgui
   ```

   To accelerate this process, you can use the following scripts:

   ### Windows

    Create a batch script create_folders.bat with the following content:

   ```bash
    @echo off
    mkdir pb_userdata\configs
    mkdir pb_userdata\historical_data
    mkdir pb_userdata\pb6\backtests
    mkdir pb_userdata\pb6\caches
    mkdir pb_userdata\pb6\configs
    mkdir pb_userdata\pb6\optimize_results
    mkdir pb_userdata\pb6\optimize_results_analysis
    mkdir pb_userdata\pb7\backtests
    mkdir pb_userdata\pb7\caches
    mkdir pb_userdata\pb7\configs
    mkdir pb_userdata\pb7\optimize_results
    mkdir pb_userdata\pb7\optimize_results_analysis
    mkdir pb_userdata\pbgui
    echo Folder structure created successfully.
   ```
   ### Linux

   Create a shell script create_folders.sh with the following content:
   ```bash
    #!/bin/bash

    mkdir -p pb_userdata/configs \
            pb_userdata/historical_data \
            pb_userdata/pb6/backtests \
            pb_userdata/pb6/caches \
            pb_userdata/pb6/configs \
            pb_userdata/pb6/optimize_results \
            pb_userdata/pb6/optimize_results_analysis \
            pb_userdata/pb7/backtests \
            pb_userdata/pb7/caches \
            pb_userdata/pb7/configs \
            pb_userdata/pb7/optimize_results \
            pb_userdata/pb7/optimize_results_analysis \
            pb_userdata/pbgui

    echo "Folder structure created successfully."
   ```
<br/>

3. **Run the docker-compose file**
    ```bash
    docker compose up --build
    ```
