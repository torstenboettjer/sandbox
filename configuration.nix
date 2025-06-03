{ config, pkgs, ... }:

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  # Import system modules
  imports =
    [
      ./hardware-configuration.nix # Include the results of the hardware scan.
      ./modules/system/lenovoflexi5.nix
      ./modules/system/powersave.nix
      ./modules/system/locales.nix
      ./modules/system/gnome.nix
      ./modules/system/zsh.nix
      ./modules/system/captive-browser.nix
    ];

  hardware.firmware = [
    pkgs.linux-firmware
  ];
  hardware.enableAllFirmware=true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Preserve display manager configuration at restart
  systemd.services.display-manager.restartIfChanged = false;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "lindar"; # Define your hostname

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Set trusted users
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.torsten = {
    isNormalUser = true;
    description = "Torsten Boettjer";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    direnv
    home-manager
    vim
    wget
  ];
}
