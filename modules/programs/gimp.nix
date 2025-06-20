{ config, pkgs, lib, ... }:

let
  icon = builtins.fetchurl {
  url = "https://upload.wikimedia.org/wikipedia/commons/0/05/GIMP_Icon.svg";
  sha256 = "sha256:a509aa4bb136b6bb7ed06261a57af13bf268d3035b1b04cd5c1779724a52dbbb";
};

in

{
  home.packages = with pkgs; [
    gimp3 # https://www.gimp.org/
  ];

  home.file.".local/share/xdg-desktop-portal/icons/GIMP_Icon.png" = {
    source = icon;
  };

  xdg.desktopEntries = {
    gimp = {
      name = "GIMP";
      genericName = "Image Editor";
      comment = "GNU Image Manipulation Program";
      exec = "gimp %u";
      terminal = false;
      categories = [ "Application" "Graphics" "RasterGraphics" "Photography"];
      icon = "$HOME/.local/share/xdg-desktop-portal/icons/GIMP_Icon.png";
    };
  };
}
