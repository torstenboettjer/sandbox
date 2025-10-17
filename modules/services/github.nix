{ config, pkgs, inputs, lib, ... }:

let
  gituser = "yourname";
  gitemail = "yourname@mail.com";
in

{
  programs = {
    git = {
      enable = true;
      userName = gituser;
      userEmail = gitemail;
    };
    # https://cli.github.com/manual/
    gh = {
      enable = true;
    };
  };
}
