{ config, lib, pkgs, ... }:

{
  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:bvn*:bvr*:bd*:svnGoogle:pnLindar:pvr*
      KEYBOARD_KEY_DB=rightmeta
      KEYBOARD_KEY_01=esc
      KEYBOARD_KEY_EA=back
      KEYBOARD_KEY_E9=forward
      KEYBOARD_KEY_E7=refresh
      KEYBOARD_KEY_91=f11
      KEYBOARD_KEY_92=print
      KEYBOARD_KEY_94=brightnessdown
      KEYBOARD_KEY_95=brightnessup
      KEYBOARD_KEY_A0=mute
      KEYBOARD_KEY_AE=volumedown
      KEYBOARD_KEY_B0=volumeup
  '';

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        meta = {
          back = "f1";
          forward = "f2";
          refresh = "f3";
          f11 = "f4";
          print = "f5";
          brightnessdown = "f6";
          brightnessup = "f7";
          mute = "f8";
          volumedown = "f9";
          volumeup = "f10";
        };
      };
    };
  };

  # Enable keyd service according to https://github.com/NixOS/nixpkgs/issues/290161
  systemd.services.keyd.serviceConfig.CapabilityBoundingSet = [
    "CAP_SETGID"
  ];
}
