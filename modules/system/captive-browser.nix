{ config, lib, pkgs, ... }:

{
  # Enable captive browser for public WiFi login
  programs.captive-browser = {
    enable = true;
    interface = "wlp0s20f3";
  };
}
