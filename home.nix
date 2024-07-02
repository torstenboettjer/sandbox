{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      hello
      gh
      gnumake
      lunarvim
    ];

    username = "torsten";
    homeDirectory = "/home/torsten";

    stateVersion = "23.11";
  };
}
