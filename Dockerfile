# Use your pre-built image
FROM halfbax/passivbot:1.1.0

# Install necessary dependencies
RUN apt-get update && apt-get install -y git && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy your entrypoint script into the container
COPY base/src/entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint to your script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]