{ config, pkgs, lib, ... }:

let
  icon = builtins.fetchurl {
  url = "https://gephi.org/clique/images/logo.svg";
  sha256 = "sha256:deb9afdf238bbe1ebbdcc317582fbcf50966fa14d35a4cc849bfb75feee2a06e";
};

in

{
  home.packages = with pkgs; [
    gephi # https://gephi.org/
  ];

  home.file.".local/share/xdg-desktop-portal/icons/gephi_logo.png" = {
    source = icon;
  };

  xdg.desktopEntries = {
    gephi = {
      name = "Gephi";
      genericName = "Graph Visualizer";
      comment = "Graph Analytics and Visualization";
      exec = "gephi";
      terminal = false;
      categories = [ "Application" ];
      icon = "/home/torsten/.local/share/xdg-desktop-portal/icons/gephi_logo.png";
    };
  };
}
