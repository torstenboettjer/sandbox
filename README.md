# NIX Home Manager
Sharing the nix home manager configuration for Debian accross multiple desktop machines

## 1. Linux Developer Environment

Activate crosh

* Name: torsten
* Size: 85 GB

## 2. Nix Packetmanager

Install the Nix package manager globally

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
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

## Enable Experimental Features

```sh
 sudo vim /etc/nix/nix.conf
```

Adding the following line

```sh
experimental-features = nix-command flakes
```
