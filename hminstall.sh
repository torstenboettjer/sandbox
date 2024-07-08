#!/bin/bash

# Exit on error
set -e

PLTFRM=$1

# clone the default home-manager configuration 
nix-shell -p gh --run "gh api user > $HOME/ghacc.json"
nix-shell -p gh --run "gh repo clone hcops/workspace"

# activating experimental features
echo "experimental-features = nix-command flakes\ntrusted-users = root ${USER}" | sudo tee -a /etc/nix/nix.conf

# add the home-manager package channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

# updte the home manager channel
nix-channel --update

# create the first home-manager generation
nix-shell '<home-manager>' -A install

# add the nix path to `.bashrc`
echo '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >> $HOME/.profile

# test the installation
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh && home-manager --version

# activate home manager
home-manager switch --flake .#$USER

# override a placeholder in a configuration file with a variable
sed -i "s/_USRNAME_/${USER}/g" $HOME/workspace/home.nix 
sed -i "s/_GHBNAME_/$(jq -r '.name' $HOME/ghacc.json)/g" $HOME/workspace/home.nix
sed -i "s/_GHBMAIL_/$(jq -r '.email' $HOME/ghacc.json)/g" $HOME/workspace/home.nix 
sed -i "s/_SYSTEM_/${PLTFRM}/g" $HOME/workspace/flake.nix 

# Check if the file exists
HOME_PATH="~/.config/home-manager/home.nix"
if [ -f "$HOME_PATH" ]; then
  echo "File '$HOME_PATH' exists. Deleting..."
  rm "$FILE_PATH"
  echo "File '$HOME_PATH' has been deleted."
else
  echo "File '$HOME_PATH' does not exist."
fi

FLAKE_PATH="~/.config/home-manager/flake.nix"
if [ -f "$FLAKE_PATH" ]; then
  echo "File '$FLAKE_PATH' exists. Deleting..."
  rm "$FILE_PATH"
  echo "File '$FLAKE_PATH' has been deleted."
else
  echo "File '$FLAKE_PATH' does not exist."
fi

for file in home.nix flake.nix; do ln -s "$HOME/workspace/$file" "$HOME/.config/home-manager/$file"; done
