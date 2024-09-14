# NixOS Installation

Channel Intro: https://jorel.dev/NixOS4Noobs/channels

## Update channels

Root:

```bash
sudo nix-channel --list

sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

User:

```bash
nix-channel --list 
home-manager https://github.com/rycee/home-manager/archive/master.tar.gz
```

