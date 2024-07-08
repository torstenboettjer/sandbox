#!/bin/bash

# Exit on error
set -e

# request platform selection
PS3="Enter a number to select your platform: "
select platform in x86_64-linux aarch64-linux
do
    echo "Selected platform: $PLTFRM"
    break
done

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
select_platform
./nxcfg.sh $PLTFRM

# add the nix path to `.bashrc`
echo -e '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >> $HOME/.profile

# tbd
rm ~/.config/home-manager/home.nix ~/.config/home-manager/flake.nix
for file in home.nix flake.nix; do ln -s "$HOME/workspace/$file" "$HOME/.config/home-manager/$file"; done


# test the installation
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh && home-manager --version

# activate home manager
home-manager switch --flake .#$USER
