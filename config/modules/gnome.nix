{ config, lib, pkgs, ... }:

{
  #services = {
    # Some applications require auth token from the gnome keyring
    #gnome.gnome-keyring.enable = true;
  #};

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    #nixd         # https://github.com/nix-community/nixd.git
    gdrive3      # https://github.com/glotlabs/gdrive
    #nix-prefetch
    #caffeine-ng
    #qogir-icon-theme
    papirus-icon-theme
    #numix-icon-theme-circle
    # Extensions
    gnomeExtensions.arcmenu
    gnomeExtensions.bluetooth-quick-connect
    gnomeExtensions.clipboard-history
    gnomeExtensions.dash-to-dock
    gnomeExtensions.gsconnect
    gnomeExtensions.lan-ip-address
    gnomeExtensions.printers
    gnomeExtensions.vitals
    gnomeExtensions.desktop-icons-ng-ding
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        arcmenu.extensionUuid
        bluetooth-quick-connect.extensionUuid
        clipboard-history.extensionUuid
        dash-to-dock.extensionUuid
        gsconnect.extensionUuid
        lan-ip-address.extensionUuid
        printers.extensionUuid
        vitals.extensionUuid
      ];
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
      speed = -0.5;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      clock-show-weekday = true;
      enable-animations = false;
      icon-theme = "Papirus-Dark";
    };
    "org/gnome/system/region" = {
      locale = "en_US.UTF-8"; # Replace with your desired locale
    };
    "org/gnome/system/location" = {
      enabled = true;
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };
    "org/gtk/settings/file-chooser" = {
      clock-format = "24h";
    };
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };
  };
}
