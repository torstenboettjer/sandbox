{ config, pkgs, inputs, ... }:

{
  # Required: Set the state version
  home.stateVersion = "25.05";

  # Modular Imports (This profile requires fewer specific program modules than 'consult')
  imports = [
    # General/Base modules
    ./modules/gnome.nix
    ./modules/captive-browser.nix
    ./modules/zed.nix
    ./modules/ghostty.nix
    ./modules/github.nix

    # NOTE: The analyst profile imports are leaner than the consult profile.
    # If the analyst profile needs Chrome or Obsidian, those modules need to be added here.
  ];

  # 💡 Consistent application packages for all profiles
  home.packages = with pkgs; [
    # Core utilities
    devenv
    gnumake
    tgpt
    lunarvim

    # Analyst-specific tools
    postgresql     # Database client/tools
  ];

  # 💡 Home Manager program configurations
  programs = {
    home-manager.enable = true;

    # Zsh configuration
    zsh = {
      enable = true;
      shellAliases = {
        # Update alias specific to the analyst profile
        update = "home-manager switch --flake ~/dotfiles#torsten-analyst";
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
    # Add any specific session variables needed for data analysis
  };

  home.file = {
    # Add any specific dotfiles required for this profile
  };
}
