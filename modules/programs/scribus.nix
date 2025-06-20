{ config, pkgs, lib, ... }:

let
  icon = builtins.fetchurl {
  url = "https://upload.wikimedia.org/wikipedia/commons/8/85/Scribus_logo.svg";
  sha256 = "sha256:13d64b26b2cef7c63da3af5576f4e70971c3dc850c1fe766db224f6be13acfb9";
};

in

{
  home.packages = with pkgs; [
    scribus # https://inkscape.org/
  ];

  home.file.".local/share/xdg-desktop-portal/icons/Scribus_logo.png" = {
    source = icon;
  };

  xdg.desktopEntries = {
    scribus = {
      name = "Scribus";
      genericName = "Desktop Publishing Application";
      comment = "Open-source Desktop Publishing Software";
      exec = "scribus %F";
      terminal = false;
      categories = [ "Application" "Graphics" "Office" "Publishing" ];
      icon = "$HOME/.local/share/xdg-desktop-portal/icons/Scribus_logo.png";
    };
  };
}
