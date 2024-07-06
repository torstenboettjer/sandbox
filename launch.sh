#!/bin/bash
# Call with 'sh <(curl -L https://raw.githubusercontent.com/hcops/repository/main/launch.sh)'

# Ask for a username and store the input in a variable
echo "Enter a username:"
read USERNAME

# Parameters
CONTAINER_NAME="nix"
DISTRO="debian/bookworm"
CONTAINER_SIZE="85G"  # Suggested size

# Enable the Linux (Beta) environment
vmc start termina

# Launch the container with specified parameters
lxc launch ${DISTRO} ${CONTAINER_NAME}

# Resize the container (example uses a root disk limit)
lxc config device override ${CONTAINER_NAME} root size=${CONTAINER_SIZE}

# Set the username (inside the container)
lxc exec ${CONTAINER_NAME} -- adduser --disabled-password --gecos "" ${USERNAME}

# Optionally install additional packages
lxc exec ${CONTAINER_NAME} -- apt-get update
lxc exec ${CONTAINER_NAME} -- apt-get install -y build-essential

# Create a configuration file
echo ${USERNAME} > username.txt

# Exit
exit