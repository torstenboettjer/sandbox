{ config, pkgs, inputs, lib, ... }:

{
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      edit = "sudo -e";
      update = "sudo nixos-rebuild switch";
      # Keep the history for searchability
      histFile = "/etc/nixos/history";
    };
  };
  programs.zsh.interactiveShellInit = ''eval "$(direnv hook zsh)"'';
}
