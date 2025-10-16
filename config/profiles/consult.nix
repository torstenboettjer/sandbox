{ config, pkgs, inputs, ... }:

{
  # Required: Set the state version
  home.stateVersion = "25.05";

  # Modular Imports (Includes modules specific to the 'consult' profile)
  imports = [
    ./modules/gnome.nix
    ./modules/captive-browser.nix
    ./modules/zed.nix
    ./modules/chrome.nix
    ./modules/obsidian.nix
    ./modules/ghostty.nix
    ./modules/github.nix

    # Graphics and publishing tools specific to the 'consult' profile
    ./modules/gimp.nix
    ./modules/inkscape.nix
    ./modules/krita.nix
    ./modules/scribus.nix
  ];

  # Consistent application packages for all profiles
  home.packages = with pkgs; [
    # Core utilities
    devenv
    gnumake
    tgpt
    lunarvim
  ];

  # 💡 Home Manager program configurations
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
