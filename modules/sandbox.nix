{ config, pkgs, ... }:

{
  # Import system modules
  imports = [
    # ./powersave.nix
    ./system/zsh.nix
    ./system/zenbook.nix
  ];

  hardware.firmware = [
    pkgs.linux-firmware
  ];

  # Hardware Options
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;


  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Preserve display manager configuration at restart
  systemd.services.display-manager.restartIfChanged = false;

  # Set trusted users
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    direnv
    home-manager
    #vim
    #wget
  ];
}
