# Author: Santosh Pandit
# Repository: https://github.com/beatquantum/docker
# License: GNU GPL v3
# Last update: 4 Oct 2024
# Description: Standard sysctl.conf optimised for vpn, webserver, fileserver and allows ipv6 and ping.

#!/bin/bash

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q "$1"
}

# Function to print entropy
show_entropy() {
    echo "Current system entropy:"
    cat /proc/sys/kernel/random/entropy_avail
}

# Show initial entropy
echo "1. Showing current entropy:"
show_entropy

# Update package list
echo "2. Updating package list..."
apt-get update

# Install haveged if not installed
if ! is_installed "haveged"; then
    echo "3. Installing haveged..."
    apt-get install -y haveged
else
    echo "3. haveged is already installed."
fi

# Enable and start haveged service
echo "4. Enabling and starting haveged service..."
systemctl enable haveged
systemctl start haveged

# Install rng-tools if not installed
if ! is_installed "rng-tools"; then
    echo "5. Installing rng-tools..."
    apt-get install -y rng-tools
else
    echo "5. rng-tools is already installed."
fi

# Configure rng-tools to use /dev/hwrng if available, otherwise /dev/urandom
echo "6. Configuring rng-tools..."
cat <<EOL > /etc/default/rng-tools
# Use /dev/hwrng if available, fallback to /dev/urandom
HRNGDEVICE=/dev/hwrng
RNGDOPTIONS="-r /dev/urandom"
EOL

# Restart rng-tools service to apply the configuration
echo "7. Restarting rng-tools service..."
systemctl restart rng-tools

# Show revised entropy
echo "8. Showing revised entropy after installing haveged and rng-tools:"
show_entropy

echo "Script completed."
