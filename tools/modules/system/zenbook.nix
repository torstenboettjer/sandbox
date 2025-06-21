{ config, lib, pkgs, ... }:

{
  # Boot Options
  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=3
    options i915 enable_dpcd_backlight=1
  '';

  hardware.firmware = [
    pkgs.linux-firmware
  ];

  # Hardware Options
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  }

  # Sound system
  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
  ];

  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  # Hardware Options
  #hardware.enableAllFirmware=true;
  #hardware.enableRedistributableFirmware = true;
}
