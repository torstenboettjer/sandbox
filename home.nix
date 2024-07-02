{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      hello
    ];

    username = "torsten";
    homeDirectory = "/home/torsten";

    stateVersion = "23.11";
  };
}
