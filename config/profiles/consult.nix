{ config, pkgs, inputs, ... }:

{
  # Required: Set the state version
  home.stateVersion = "25.05";

  # Modular Imports (Includes modules specific to the 'consult' profile)
  imports = [
    "${programModulesPath}/gnome.nix"
    "${programModulesPath}/captive-browser.nix"
    "${programModulesPath}/zed.nix"
    "${programModulesPath}/chrome.nix"
    "${programModulesPath}/obsidian.nix"
    "${programModulesPath}/ghostty.nix"

    # Graphics and publishing tools specific to the 'consult' profile
    "${programModulesPath}/gimp.nix"
    "${programModulesPath}/inkscape.nix"
    "${programModulesPath}/krita.nix"
    "${programModulesPath}/scribus.nix"
    "${programModulesPath}/zsh.nix"

    # SERVICE MODULES (e.g., ~/.config/modules/services/...)
    # Importing github.nix via the dedicated service path
    "${serviceModulesPath}/github.nix"
  ];

  # Consistent application packages for all profiles
  home.packages = with pkgs; [
    # Core utilities
    devenv
    gnumake
    tgpt
    lunarvim
  ];

  # Home Manager program configurations
  programs = {
    home-manager.enable = true;

    # Zsh configuration
    zsh = {
      enable = true;
      shellAliases = {
        # Update alias specific to the consult profile
        update = "home-manager switch --flake ~/dotfiles#torsten-consult";
        hl = "history | grep";
      };
    };

    # Direnv configuration
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

  # Systemd User Service Start Mode
  systemd.user.startServices = "sd-switch";

  # Managed Files and Session Variables (Placeholder sections)
  home.sessionVariables = {
    # Add any specific session variables needed for consultation work
  };

  home.file = {
    # Add any specific dotfiles required for this profile
  };
}
