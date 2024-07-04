# NIX Home Manager on CROSH
Sharing the nix home manager configuration for Debian accross multiple desktop machines

## 1. Linux Developer Environment

Activate crosh

* Name: torsten
* Size: 85 GB

## 2. Nix Packetmanager

Install the Nix package manager globally

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
```
## 3. Home-Manager Repository

Use `gh` nix package to clone the github repository

```sh
nix-shell -p gh
```

Log into github

```sh
gh auth login
```

Clone home manager repository

```sh
gh repo clone torstenboettjer/home_manager
```

## 4. Experimental Features

Enabling flakes requires to enable experimental features by appending the following line to `/etc/nix/nix.conf`:

```sh
echo -e "experimental-features = nix-command flakes\ntrusted-users = root torsten" | sudo tee -a /etc/nix/nix.conf
```

Run functional test

```sh
nix run nixpkgs#hello
```

## 5. Home-Manager Channel

Add and than update the appropriate channel, e.g. to follow the Nixpkgs master channel run:

```sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

## 6. Installation

Create the first home-manager generation

```sh
nix-shell '<home-manager>' -A install
```

Add the nix path to `.bashrc`

```sh
echo -e '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >> $HOME/.profile
```

Test the installation

```sh
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
home-manager --version
```

Make sure that the right system is active in *~/home_manager/flake.nix*

```nix
  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      # system = "x86_64-linux";
      system = "aarch64-linux";
```

Link the home manager configruation files to the repository

```sh
rm ~/.config/home-manager/home.nix ~/.config/home-manager/flake.nix
for file in home.nix flake.nix; do ln -s "$HOME/home_manager/$file" "$HOME/.config/home-manager/$file"; done
```

Run the Makefile to update the minimal configuration

```sh
cd ~/home_manager
make update
```

Activating direnv, an environment switcher for the shell that automatically loads and unloads environment variables, when the directory is changed

```sh
echo -e 'eval "$(direnv hook bash)"' >> $HOME/.bashrc
```
