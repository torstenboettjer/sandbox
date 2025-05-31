{ config, pkgs, lib, ... }:

let
  icon = builtins.fetchurl {
  url = "https://upload.wikimedia.org/wikipedia/commons/3/31/Calligra_Krita_icon.svg";
  sha256 = "sha256:363acb3f5bc84f26b56224ac79915b2b7fc31c2047496666c4d4c7c195d68d1a";
};

in

{
  home.packages = with pkgs; [
    krita # https://www.krita.org/
  ];

  home.file.".local/share/xdg-desktop-portal/icons/Calligra_Krita_icon.png" = {
    source = icon;
  };

  xdg.desktopEntries = {
    krita = {
      name = "Krita";
      genericName = "Image Editor";
      comment = "Digital Painting";
      exec = "krita %F";
      terminal = false;
      categories = [ "Application" "Graphics" ];
      icon = "/home/torsten/.local/share/xdg-desktop-portal/icons/Calligra_Krita_icon.png";
    };
  };
}
