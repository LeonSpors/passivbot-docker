# Base image
FROM python:3.10-slim-buster

# Install dependencies
RUN apt update && apt install -y git build-essential curl rclone && apt clean

# Install the latest version of Rust and Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create working directories
WORKDIR /app

# Setup virtual environments
RUN python3 -m venv /venv_pbgui && \
    python3 -m venv /venv_pb6 && \
    python3 -m venv /venv_pb7

# Copy the entrypoint script from the src folder
COPY ./src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define build arguments for Git branches
ARG PB6_VERSION=v6.1.4b
ARG PB7_VERSION=master
ARG PBGUI_VERSION=main

# Set environment variables for the entrypoint script
ENV PB6_VERSION=${PB6_VERSION}
ENV PB7_VERSION=${PB7_VERSION}
ENV PBGUI_VERSION=${PBGUI_VERSION}

# Expose the required port
EXPOSE 8501

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]