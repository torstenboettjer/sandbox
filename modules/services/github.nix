{ config, pkgs, inputs, lib, ... }:

let
  gituser = "torstenboettjer";
  gitemail = "torsten.boettjer@gmail.com";
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
