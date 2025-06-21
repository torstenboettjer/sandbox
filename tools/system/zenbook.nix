{ config, lib, pkgs, ... }:

let
  username = "torsten";
  homedir = "/home/${username}";
in

{
  # Firmware Options
  hardware.enableAllFirmware=true;
  hardware.enableRedistributableFirmware = true;

  # Enable Bluetooth Firmware
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  hardware.firmware = with pkgs; [
    linux-firmware
    firmwareLinuxNonfree
  ];

  # For ASUS hardware specifically
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=n
    options asus_nb_wmi wapf=4
  '';

  services = {
    blueman.enable = true;
    dbus.enable = true;
  };

  # Switch off TPM
  systemd.tpm2.enable = false;
  environment.systemPackages = with pkgs; [
    bluez
  ];

  # Maintain SSD performance and longevity
  services.fstrim.enable = true;
}
