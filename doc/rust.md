# RUST installation

## Enable rustup toolchain
Adding rust toolchain to `/etc/nixos/configuration.nix` to enable [tools](https://zed.dev/docs/languages/rust) like the [rust analyzer],(https://github.com/rust-lang/rust-analyzer) or tree-sitter code parser](https://github.com/tree-sitter/tree-sitter-rust).

# Enable inlay hints through the configuration file
Locate or create the configuration file in ~/.zed/config.json (for Linux and macOS) or C:\Users\<YourUsername>\.zed\config.json (for Windows) and add the appropriate [settings](https://zed.dev/docs/languages/rust) for the language server.

```sh
mkdir ~/.zed && zed ~/.zed/config.json
```
