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
      extraConfig.github.token = "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";
    };
    gh.enable = true;     # https://cli.github.com/manual/
  };
}
