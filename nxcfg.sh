#!/bin/bash

GHBNAME=$(jq -r '.name' $HOME/ghacc.json)
GHBMAIL=$(jq -r '.email' $HOME/ghacc.json)
TGSYS=$1

# override a placeholder in a configuration file with a variable
sed -i "s/_USRNAME_/${USER}/g" ./home.nix 
sed -i "s/_GHBNAME_/${GHBNAME}/g" ./home.nix
sed -i "s/_GHBMAIL_/${GHBMAIL}/g" ./home.nix 
sed -i "s/_SYSTEM_/${TGSYS}/g" ./flake.nix 
