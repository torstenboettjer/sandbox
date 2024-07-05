#!/bin/bash
# Still draft -don't use


# Exit on error
set -e

# create log file
touch ./setup.log

# https://nixos.org/
if command -v nix &> /dev/null; then
    echo "Installing nix single user mode..."
    curl -LO https://nixos.org/nix/install
    chmod +x ./install
    ./install --daemon --yes
    . $HOME/.nix-profile/etc/profile.d/nix.sh
    echo "--> done"
    NIXVERSION=$(nix --version)
    echo "$NIXVERSION is installed." >> ./setup.log
else
    NIXVERSION=$(nix --version)
    echo "$NIXVERSION is installed." >> ./setup.log
fi

# remove nix install script
rm ./install

#https://nixos.wiki/wiki/Home_Manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
echo '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >>  ~/.profile
home-manager build
