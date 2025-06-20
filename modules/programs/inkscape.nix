{ config, pkgs, lib, ... }:

let
  icon = builtins.fetchurl {
  url = "https://upload.wikimedia.org/wikipedia/commons/0/0d/Inkscape_Logo.svg";
  sha256 = "sha256:8388c6cc93a0e44ba6979c8a6f3273c6bb7860e19208c3c9e9f86057733debc0";
};

in

{
  home.packages = with pkgs; [
    inkscape # https://inkscape.org/
    imagemagick
  ];

  home.file.".local/share/xdg-desktop-portal/icons/Inkscape_Logo.png" = {
    source = icon;
  };

  xdg.desktopEntries = {
    inkscape = {
      name = "Inkscape";
      genericName = "Vector Graphics Editor";
      comment = "Create and Edit Scalable Vector Graphics Images";
      exec = "inkscape %F";
      terminal = false;
      categories = [ "Application" "Graphics" "VectorGraphics" ];
      icon = "$HOME/.local/share/xdg-desktop-portal/icons/Inkscape_Logo.png";
    };
  };
}
