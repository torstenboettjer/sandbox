{ config, pkgs, inputs, lib, ... }:

{
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -la";
      edit = "sudo -e";
      update = "cd /etc/nixos && sudo nixos-rebuild switch --flake '.#nixbook-default' --impure";
      consult = "cd /etc/nixos && sudo nixos-rebuild switch --flake '.#nixbook-consult' --impure";
      # Keep the history for searchability
      histFile = "/etc/nixos/history";
    };
  };
  programs.zsh.interactiveShellInit = ''eval "$(direnv hook zsh)"'';
}
