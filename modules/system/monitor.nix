{ config, lib, pkgs, ... }:

let
  monitorsXmlContent = builtins.readFile ./.config/monitors.xml;
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in

{
  # Monitor settings for entry screen
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  ];

  # Bootloader key option for resolution
  boot.loader.systemd-boot.consoleMode = "max"; # Or "auto", or a specific mode number

  # Silent boot without kernel messages
  boot.kernelParams = ["quiet" "splash"];
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

  # Set boot loader screen
  boot.plymouth = {
    enable = true;
    theme = "breeze";  # Example theme; others include "rings" or "lone" :cite[1]:cite[2].
  };
}
