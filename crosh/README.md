## Update lix

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

### Update devenv

```sh
nix-env --upgrade --attr devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable
```
