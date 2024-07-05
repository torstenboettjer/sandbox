#!/bin/bash

# Parameters
CONTAINER_NAME="nix"
DISTRO="debian/bookworm"
USERNAME="torsten"
CONTAINER_SIZE="85G"  # Example size

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

# Exit
exit

