# NixOS

NixOS is a reproducible Linux distribution built on the Nix package manager. Its declarative configuration model allows you to define the entire state of your system in a single file, making upgrades and rollbacks trivial. 

## Installation

For the base install, download the latest [NixOS](https://nixos.org/download/#download-nixos) image and create a bootable USB [flash drive](https://nixos.org/manual/nixos/stable/index.html#sec-booting-from-usb). On a Linux system the dd command creates a boot drive, the correct device name for your USB drive (e.g., /dev/sdb) should be adjusted.

```sh
sudo dd if=/path/to/nixos.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

With the bootable USB drive created, restart the computer and boot from it. Usually the boot menu is entered pressing a specific key during startup (often F2, F12, Del, or Esc). Once you boot into the live desktop, select the "Install NixOS" application. Launch it to start the Calamares installer. The installer will set the region and time zone, select a keyboard layout, handle partitioning, create a user account and set a password. Once the installation is complete, reboot the computer.

## Prepare the system

Adjusting allowed users in [configuration.nix](https://nixos.org/manual/nixos/stable/options.html#opt-nix.settings.allowed-users)

```nix
nix.settings.trusted-users = [ "root" "@wheel" ];
```

Check the current [channels](https://jorel.dev/NixOS4Noobs/channels) for the sudo user

```sh
sudo nix-channel --list
```

Only the channel related installed version should be returned. Moving to nixos 'unstable' channel for the latest updates and adding the hardware channel as sudo user

```sh
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
```

Checking the channels as user, nothing shoud be set

```sh
nix-channel --list
```

Adding the home manager channel for home manager packages

```sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
```

## Housekeeping

`nix-system-clean(){ sudo nix-env --delete-generations old; sudo nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"; sudo nix-collect-garbage -d; sudo nix-store --optimise; sudo nixos-rebuild boot; }`

```nix
sudo nix-env --delete-generations old; sudo nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"; sudo nix-collect-garbage -d; sudo nix-store --optimise; sudo nixos-rebuild boot;
```
und

`nix-user-clean(){ nix-env --delete-generations old; nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"; nix-collect-garbage -d; }`

```nix
nix-env --delete-generations old; nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"; nix-collect-garbage -d;
```

## Channel Refresh (root und der user)

```sh
sudo nix-channel --update && nix-channel --update
```

## System und home-manager upgrade:

```sh
cd /etc/nixos && sudo nix flake update
update
```
