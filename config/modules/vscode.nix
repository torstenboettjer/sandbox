{ config, pkgs, inputs, lib, ... }:

{
  programs = {
    vscode = {
      enable = true; # https://code.visualstudio.com/.visualstudio.com/
      package = pkgs.vscode-fhs;
      profiles.default.enableUpdateCheck = false;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        emroussel.atomize-atom-one-dark-theme
        yzhang.markdown-all-in-one
        mechatroner.rainbow-csv
        redhat.vscode-yaml
        ritwickdey.liveserver
        ms-vscode.makefile-tools
        jnoortheen.nix-ide
        esbenp.prettier-vscode
        rust-lang.rust-analyzer
        fill-labs.dependi
        njpwerner.autodocstring
      ];
      # Settings
      profiles.default.userSettings = {
        # General
        "window.titleBarStyle" = "custom";
        "editor.fontFamily" = "'Jetbrains Mono', 'monospace'";
        "workbench.colorTheme" = "Atomize";
        "git.autofetch" = true;
        "autoDocstring.docstringFormat" = "google";
        "dependi.go.enabled" = true;
        "dependi.rust.enabled" = true;
        "dependi.python.enabled" = true;
        "liveServer.settings.port" = 5500;
        "nix.enableLanguageServer" = false;
      };
    };
  };
}
