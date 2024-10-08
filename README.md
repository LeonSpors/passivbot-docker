## Dockerized Passivbot with pbgui

[![Static Badge](https://img.shields.io/badge/docker-pull-blue)](https://hub.docker.com/r/halfbax/passivbot)
![Static Badge](https://img.shields.io/badge/Compatible%20with-Passivbot%20v6-green)
![Static Badge](https://img.shields.io/badge/Compatible%20with-Passivbot%20v7-green)



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
1. **Clone the Repository**
   
    First, clone this repository to your local machine using the following command:

    ```bash
    git clone https://github.com/LeonSpors/passivbot-docker.git
    ```
    
    <br>

2. **Configure .env file**
   
    Open the .env file and set the following variable:

    ```bash
    USERDATA=<location of the current folder>
    ```

    <br>

3. **Run setup**

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

    ### Windows

    Simply run the setup.bat file located in the tools folder:

    ```bash
    tools\setup.bat
    ```

    ### Linux

    For Linux, you’ll first need to grant execute permissions to the setup.sh script and then run it:

    ```bash
    chmod +x ./tools/setup.sh
    ./setup.sh
    ```

    <br>

4. **Run the docker-compose file**
    ```bash
    docker compose up --build
    ```

<br>

### FAQ

#### What is the default password?
The default password is `your-password`. You can change it in the file located at `pb_userdata/configs/secrets.toml`.

<br>

#### Can I use Rclone for RBRemote?
Yes! To use the Rclone feature of PBShare, simply add your `rclone.conf` file to the `pb_userdata/configs` directory.

<br>

#### Where should I place my API keys?
Add your `api-keys.json` file to the `pb_userdata/configs` folder to configure API access.

<br>

#### How to configure PBGUI?
Add your `pbgui.ini` file to the `pb_userdata/configs` folder.

<br>

#### How do I change the PBGUI password?
Change the password in the `secrets.toml` file.

<br>

#### Can I access optimization, backtesting, or configuration files?
Absolutely. All optimization, backtesting, and config files are stored in the `pb_userdata` directory under the appropriate subfolders (e.g., `pb6`, `pb7`).

<br>

#### How can I update PBGUI and Passivbot?
To update the software, you need to rebuild the container. Simply run the following commands:
```bash
docker-compose down
docker-compose up --build
```

<br>

#### How can I get shell access to the system?
You can access the system by attaching to the running Docker container. Use the following command:

```bash
docker exec -it <container_id> /bin/bash
```


