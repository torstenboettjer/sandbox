{ config, pkgs, lib, programModulesPath, serviceModulesPath, ... }:

{
  # Required: Set the state version
  home.stateVersion = "25.05";

  # Modular Imports, separating programs and services
  imports = [
    # PROGRAM MODULES (e.g., ~/.config/modules/programs/...)
    "${programModulesPath}/gnome.nix"
    "${programModulesPath}/captive-browser.nix"
    "${programModulesPath}/zed.nix"
    "${programModulesPath}/chrome.nix"
    "${programModulesPath}/claude.nix"
    "${programModulesPath}/ghostty.nix"
    "${programModulesPath}/obsidian.nix"

    # SERVICE MODULES (e.g., ~/.config/modules/services/...)
    # Importing github.nix via the dedicated service path
    "${serviceModulesPath}/github.nix"
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
