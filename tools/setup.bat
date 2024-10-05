@echo off
REM Save the current directory
set "CURRENT_DIR=%CD%"
REM Change to the parent directory
pushd ..

REM Set USERDATA
set "USERDATA=%CD%"

REM Return to the original directory
popd

REM Ask for user confirmation
set /p "CONFIRM=Do you want to create the folder and files under this location? %USERDATA% (y/n): "
if /i "%CONFIRM%" neq "y" (
    echo Operation canceled.
    exit /b
)

REM Create the necessary directory structure
mkdir "%USERDATA%\configs" 2>nul
mkdir "%USERDATA%\historical_data" 2>nul
mkdir "%USERDATA%\pb6\backtests" 2>nul
mkdir "%USERDATA%\pb6\caches" 2>nul
mkdir "%USERDATA%\pb6\configs" 2>nul
mkdir "%USERDATA%\pb6\optimize_results" 2>nul
mkdir "%USERDATA%\pb6\optimize_results_analysis" 2>nul
mkdir "%USERDATA%\pb7\backtests" 2>nul
mkdir "%USERDATA%\pb7\caches" 2>nul
mkdir "%USERDATA%\pb7\configs" 2>nul
mkdir "%USERDATA%\pb7\optimize_results" 2>nul
mkdir "%USERDATA%\pb7\optimize_results_analysis" 2>nul
mkdir "%USERDATA%\pbgui" 2>nul

echo Folder structure created successfully.

REM Create secrets.toml if it doesn't exist
if not exist "%USERDATA%\configs\secrets.toml" (
    echo password = "your-password" > "%USERDATA%\configs\secrets.toml"
    echo secrets.toml created.
) else (
    echo secrets.toml already exists.
)

REM Create api-keys.json if it doesn't exist
if not exist "%USERDATA%\configs\api-keys.json" (
    echo {} > "%USERDATA%\configs\api-keys.json"
    echo api-keys.json created.
) else (
    echo api-keys.json already exists.
)

REM Create pbgui.ini if it doesn't exist
if not exist "%USERDATA%\configs\pbgui.ini" (
    (
        echo [main]
        echo pbdir = /app/pb6
        echo pbvenv = /venv_pb6/bin/python
        echo pb7dir = /app/pb7
        echo pb7venv = /venv_pb7/bin/python
        echo pbname = docker
    ) > "%USERDATA%\configs\pbgui.ini"
    echo pbgui.ini created.
) else (
    echo pbgui.ini already exists.
)

echo File creation check completed in %USERDATA% directory.
pause