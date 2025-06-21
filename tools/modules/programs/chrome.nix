{ config, pkgs, inputs, lib, ... }:

{
  programs = {
    chromium = {
      enable = true;
      package = pkgs.google-chrome;
    };
  };
}
