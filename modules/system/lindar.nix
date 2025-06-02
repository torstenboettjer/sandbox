{ config, lib, pkgs, ... }:

{
  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=3
    options i915 enable_dpcd_backlight=1
  '';
}
