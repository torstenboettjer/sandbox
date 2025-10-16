{ config, pkgs, ... }:

{
  # Core System Modules
  imports = [
    ./users.nix # Defines 'alice', 'bob'
    ./security.nix
  ];

  # System-wide settings
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  # Base service installation
  services.openssh.enable = true;

  # Enable direnv globally for all users
  programs.direnv = {
    enable = true;
    enableFlakes = true;
  };
}
