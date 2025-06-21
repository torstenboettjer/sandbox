{ config, pkgs, ... }:

{
  # Import system modules
  imports = [
    # ./powersave.nix
    ./system/zsh.nix
    ./system/monitor.nix
    ./system/powersave.nix
    ./system/zenbook.nix
  ];

  nix = {
    package = pkgs.nix;
    # Enable experimental features
    settings.experimental-features = [ "nix-command" "flakes" ];
    # Set trusted users
    settings.trusted-users = [ "root" "@wheel" ];
  };

  # Preserve display manager configuration at restart
  systemd.services.display-manager.restartIfChanged = false;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    direnv
    home-manager
  ];
}
