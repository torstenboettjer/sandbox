# NixOS Installation
For the base install, download the latest [NixOS](https://nixos.org/download/#download-nixos) image and create a bootable USB [flash drive](https://nixos.org/manual/nixos/stable/index.html#sec-booting-from-usb). 

## Prepare the system

[Channel Intro](https://jorel.dev/NixOS4Noobs/channels)

Root:

```sh
sudo nix-channel --list
```

```sh
sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

User:

```sh
nix-channel --list 
```

```sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
```

## Install Home-Manager


Adding allowed users to [configuration.nix](https://nixos.org/manual/nixos/stable/options.html#opt-nix.settings.allowed-users)

```nix
nix.settings.trusted-users = [ "root" "@wheel" ];
```

Run the install script
```nix
nix-shell '<home-manager>' -A install
```

Add home-manager to the profile

```sh
echo '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >> ~/.profile
```

## Housekeeping

```nix
nix-system-clean(){ sudo nix-env --delete-generations old; sudo nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"; sudo nix-collect-garbage -d; sudo nix-store --optimise; sudo nixos-rebuild boot; }
```
und

```nix
nix-user-clean(){ nix-env --delete-generations old; nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"; nix-collect-garbage -d; }
```

## Channel Refresh (root und der user)

```sh
sudo nix-channel --update && nix-channel --update
```

## System und home-manager upgrade:

```sh
sudo nixos-rebuild switch && home-manager switch 
```
