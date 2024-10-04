# Author: Santosh Pandit
# Repository: https://github.com/beatquantum/docker
# License: GNU GPL v3
# Last update: 4 Oct 2024
# Description: Deploy standard sysctl.conf and harden SSH configuration

# Use a specific Ubuntu version for consistency
FROM ubuntu:24.04

# Set non-interactive frontend for package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages including ca-certificates to fix SSL issues
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    # Clone your repository and copy sysctl.conf
    && git clone https://github.com/beatquantum/docker.git /tmp/repo \
    && cp /tmp/repo/sysctl.conf /etc/sysctl.conf \
    && sysctl -p \
    # Copy hardened sshd_config to the correct location
    && cp /tmp/repo/sshd_config /etc/ssh/sshd_config \
    # Remove existing SSH host keys
    && rm /etc/ssh/ssh_host_* \
    # Generate new ed25519 SSH host key
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" \
    # Filter moduli for safe primes and replace the moduli file
    && awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.safe \
    && mv /etc/ssh/moduli.safe /etc/ssh/moduli \
    # Clean up temporary files and packages
    && rm -rf /tmp/repo \
    && apt-get remove --purge -y git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Expose the SSH port (change as needed)
EXPOSE 49022

# Restart SSH service after changes
RUN systemctl restart ssh

# Set default command
CMD ["/usr/sbin/sshd", "-D"]

# Optional: Add a health check to monitor the SSH service
HEALTHCHECK CMD pgrep sshd > /dev/null || exit 1
