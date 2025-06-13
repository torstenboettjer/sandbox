{ config, lib, pkgs, ... }:

{
  # Boot Options
  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=3
    options i915 enable_dpcd_backlight=1
  '';

  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  # Hardware Options
  #hardware.enableAllFirmware=true;
  #hardware.enableRedistributableFirmware = true;

}
