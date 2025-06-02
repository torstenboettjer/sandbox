{ config, lib, pkgs, ... }:

let
  monitorsXmlContent = builtins.readFile /home/torsten/.config/monitors.xml;
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in

{
  # Monitor settings for entry screen
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  ];
}
