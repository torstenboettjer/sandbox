{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      hello
      gh
      gnumake
      lunarvim
      vscode
    ];

    username = "torsten";
    homeDirectory = "/home/torsten";

    stateVersion = "23.11";
  };
}
