# NixOS Installation


## Update channels

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

Channelsrefresh (root und der user)

```sh
sudo nix-channel --update && nix-channel --update
```

Adding allowed users to [configuration.nix](https://nixos.org/manual/nixos/stable/options.html#opt-nix.settings.allowed-users)

System und home-manager upgrade:

```sh
sudo nixos-rebuild switch && home-manager switch 
```


Housekeeping (!):
```sh
nix-system-clean(){ sudo nix-env --delete-generations old; sudo nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"; sudo nix-collect-garbage -d; sudo nix-store --optimise; sudo nixos-rebuild boot; }
```
und

```sh
nix-user-clean(){ nix-env --delete-generations old; nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"; nix-collect-garbage -d; }
```


