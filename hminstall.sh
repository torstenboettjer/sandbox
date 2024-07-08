#!/bin/bash

# Exit on error
set -e

# Write a function that provides the user with a choice to select a platform and returns the selected option into a variable
function select_platform() {
    echo "Please select a platform:"
    echo "1) x86_64"
    echo "2) aarch64"

    read -p "Enter your choice (1-2): " choice

    case $choice in
        1)
            platform="x86_64-linux"
            ;;
        2)
            platform="aarch64-linux"
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            select_platform
            ;;
    esac

    echo "You selected: $platform"
    return $platform
}

PLTFRM=$(select_platform)

# create log file
touch ./setup.log

# clone the default home-manager configuration 
nix-shell -p gh --run "gh api user > $HOME/ghacc.json"
nix-shell -p gh --run "gh repo clone hcops/workspace"

# activating experimental features
echo -e "experimental-features = nix-command flakes\ntrusted-users = root ${USER}" | sudo tee -a /etc/nix/nix.conf

# add the home-manager package channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

# updte the home manager channel
nix-channel --update

# create the first home-manager generation
nix-shell '<home-manager>' -A install

# configure nix files
./nxcfg.sh $PLTFRM

# add the nix path to `.bashrc`
echo -e '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >> $HOME/.profile

# test the installation
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh && home-manager --version

# activate home manager
home-manager switch --flake .#$USER
