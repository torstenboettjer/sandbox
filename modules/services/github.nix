{ config, pkgs, inputs, lib, ... }:

let
  gituser = "...";
  gitemail = "...";
  ghtoken = "...";
in

{
  programs = {
    git = {
      enable = true;
      userName = gituser;
      userEmail = gitemail;
      extraConfig.github.token = ghtoken;
    };
    # https://cli.github.com/manual/
    gh = {
      enable = true;
    };
  };
}
