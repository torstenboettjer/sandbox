# Windows Sandbox

On Windoows the sandbox is installed on WSL

## 1. Install Lix Packet Manager

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Source: https://lix.systems/

## 2. Add nix channels
```sh
sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

nix-channel --update
nix-shell '<home-manager>' -A install
```

## 3. Update lix

### Switch in su mode
```sh
sudo su && passwd pushp.vashisht
```

### Run update command
```sh
nix run \
     --experimental-features "nix-command flakes" \
     --extra-substituters https://cache.lix.systems --extra-trusted-public-keys "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o=" \
     'git+https://git.lix.systems/lix-project/lix?ref=refs/tags/2.91.1' -- \
     upgrade-nix \
     --extra-substituters https://cache.lix.systems --extra-trusted-public-keys "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
```



