#!/bin/bash
# Still draft -don't use

# Exit on error
set -e

# create log file
touch ./setup.log

# https://nixos.org/
# if command -v nix &> /dev/null; then
#     echo "Installing nix single user mode..."
#     curl -LO https://nixos.org/nix/install
#     chmod +x ./install
#     ./install --daemon --yes
#     . $HOME/.nix-profile/etc/profile.d/nix.sh
#     echo "--> done"
#     NIXVERSION=$(nix --version)
#     echo "$NIXVERSION is installed." >> ./setup.log
# else
#     NIXVERSION=$(nix --version)
#     echo "$NIXVERSION is installed." >> ./setup.log
# fi

# clone the default home-manager configuration 
gh repo clone hcops/workspace

# activating experimental features
echo -e "experimental-features = nix-command flakes\ntrusted-users = root torsten" | sudo tee -a /etc/nix/nix.conf

# add the home-manager package channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

# updte the home manager channel
nix-channel --update

# create the first home-manager generation
nix-shell '<home-manager>' -A install

# add the nix path to `.bashrc`
echo -e '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >> $HOME/.profile

# test the installation
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh && home-manager --version

# remove nix install script
# rm ./install
