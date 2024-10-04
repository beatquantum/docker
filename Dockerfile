# Author: Santosh Pandit
# Repository: https://github.com/beatquantum/docker
# License: GNU GPL v3
# Last update: 4 Oct 2024
# Description: Deploy standard sysctl.conf

# Use a specific Ubuntu version for consistency
FROM ubuntu:24.04

# Set non-interactive frontend for package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and clean up cache in a single RUN command
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && git clone https://github.com/beatquantum/docker.git /tmp/repo \
    && cp /tmp/repo/sysctl.conf /etc/sysctl.conf \
    && sysctl -p \
    && rm -rf /tmp/repo \
    && apt-get remove --purge -y git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set default command
CMD ["bash"]

# Optional: Add a health check to monitor the container
HEALTHCHECK CMD sysctl -a > /dev/null || exit 1
