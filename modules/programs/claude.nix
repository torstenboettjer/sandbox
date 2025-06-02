{ config, pkgs, inputs, lib, ... }:

let
  icon = builtins.fetchurl {
  url = "https://upload.wikimedia.org/wikipedia/commons/1/14/Anthropic.png";
  sha256 = "sha256:b62cd00b696604b67e61f68d5b6b959a7d0803ba44d921a1bf811b53c0f743e6";
};
in

{
  home.packages = with pkgs; [
    inputs.claude-desktop.packages.${pkgs.system}.default
    nodejs
  ];

  home.file.".local/share/xdg-desktop-portal/icons/Anthropic.png" = {
    source = icon;
  };

  xdg.desktopEntries = {
    claude = {
      name = "Claude";
      genericName = "Claude Desktop";
      comment = "Claude Chat App";
      exec = "claude-desktop";
      terminal = false;
      categories = [ "Application" ];
      icon = "/home/torsten/.local/share/xdg-desktop-portal/icons/Anthropic.png";
    };
  };
}
