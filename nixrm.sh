#!/bin/bash
CURRENT_DIR=$(pwd)

# Function to delete a list of files in a directory
delete_files() {
    # Loop through each argument passed to the function
    for file in "$@"; do
        # Check if the file exists in the current directory
        if [ -e "$file" ]; then
            # Delete the file
            sudo rm "$file"
            echo "Deleted file: $file"
        else
            echo "File not found: $file"
        fi
    done
}

# Function to delete a list of files in a directory
backup_config() {
    # Loop through each argument passed to the function
    for config in "$@"; do
        # Check if the file exists in the current directory
        if [ -e "$config" ]; then
            # Delete the file
            sudo cp "$config" "$config".backup
            echo "Backed up file: $config"
        else
            echo "File not found: $config"
        fi
    done
  }

# Stop the Nix daemon
sudo systemctl stop nix-daemon 2>/dev/null || sudo service nix-daemon stop 2>/dev/null

# Remove Nix package manager and store
sudo rm -rf /nix

# Remove user-specific Nix configurations
rm -rf ~/.nix-profile ~/.nix-defexpr ~/.nix-channels ~/.nixpkgs

# Remove system-wide Nix configurations
sudo rm -rf /etc/nix /etc/profile.d/nix.sh

# Backup devenv.nix and devenv.yaml files
backup_config "$CURRENT_DIR/devenv.nix" "$CURRENT_DIR/devenv.yaml"

# Remove Nix-related files in the current directory
delete_files "$CURRENT_DIR/devenv.nix" "$CURRENT_DIR/devenv.yaml" "$CURRENT_DIR/.envrc"

# Remove Nix-related backup files
delete_files "/etc/bash.bashrc.backup-before-nix" "/etc/zsh.zshrc.backup-before-nix" "/etc/bashrc.backup-before-nix" "/etc/zshrc.backup-before-nix"

"/etc/nix /nix" "/var/root/.nix-profile" "/var/root/.nix-defexpr" "/var/root/.nix-channels" "$USER/.nix-profile" "$USER/.nix-defexpr" "$USER/.nix-channels"

# Remove Nix daemon users (if applicable)
for user in nixbld{1..10}; do
    sudo userdel -r $user 2>/dev/null
done

# Remove Nix entries from shell profiles
sudo sed -i '/nix.sh/d' ~/.bashrc ~/.profile /etc/bash.bashrc

# Verify removal
echo "Verification of removal:"
ls -la /nix
ls -la ~/.nix-profile ~/.nix-defexpr ~/.nix-channels ~/.nixpkgs
ls -la /etc/nix /etc/profile.d/nix.sh

echo "Nix has been removed from the system."
