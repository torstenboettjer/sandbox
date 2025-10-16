{ config, pkgs, inputs, ... }:

{
  # 💡 Required: Set the state version
  home.stateVersion = "25.05"; # Updated to 25.05 based on your old configuration

  # 💡 Modular Imports (Assuming these files are moved/re-created under ~/dotfiles/modules)
  imports = [
    ./modules/gnome.nix
    ./modules/captive-browser.nix
    ./modules/zed.nix
    ./modules/chrome.nix
    ./modules/claude.nix
    ./modules/ghostty.nix
    ./modules/obsidian.nix
    ./modules/github.nix
  ];

  # Consistent application packages for all profiles
  home.packages = with pkgs; [
    # Basic command-line tools (from previous and current list)
    tmux
    git
    ripgrep
    fd
    wget
    devenv
    gnumake
    tgpt
    lunarvim
  ];

  # Home Manager program configurations
  programs = {
    # This explicitly enables Home Manager to manage its own configuration
    home-manager.enable = true;

    # Zsh Configuration
    zsh = {
      enable = true;
      shellAliases = {
        update = "home-manager switch --flake ~/dotfiles#torsten-default";
        hl = "history | grep";
      };
    };

    # Direnv configuration (used in conjunction with system-level direnv enablement)
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    # General command-line tools
    jq.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
