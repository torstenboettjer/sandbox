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

Use `gh` nix package to clone the home manager repository

```sh
nix-shell -p gh
```

Log into guthub

```sh
gh auth login
```
