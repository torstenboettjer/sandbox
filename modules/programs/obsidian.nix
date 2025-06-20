{ config, pkgs, lib, ... }:

let
  icon = builtins.fetchurl {
  url = "https://upload.wikimedia.org/wikipedia/commons/1/10/2023_Obsidian_logo.svg";
  sha256 = "sha256:9cf13f4c8029f1f9c1f813c60f012a7a8ff0129b587b276843eb857230c21531";
};

in

{
  home.packages = with pkgs; [
    obsidian # https://obsidian.md/
  ];

  home.file.".local/share/xdg-desktop-portal/icons/obsidian.png" = {
    source = icon;
  };

  xdg.desktopEntries = {
    obsidian = {
      name = "Obsidian";
      genericName = "Text Editor";
      comment = "Markdown Notetaking App";
      exec = "obsidian";
      terminal = false;
      categories = [ "Application" ];
      icon = "$HOME/.local/share/xdg-desktop-portal/icons/obsidian.png";
    };
  };
}
