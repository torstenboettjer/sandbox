{ config, pkgs, inputs, lib, ... }:

{
  programs = {
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        background-blur-radius = 20;
        theme = "catppuccin-mocha";
        #theme = "dark:catppuccin-mocha,light:catppuccin-latte";
        window-theme = "ghostty";
        #background-opacity = 0.8;
        minimum-contrast = 1.1;
        font-family = "Arimo";
        font-size = 10;
        keybind = [
          "ctrl+h=goto_split:left"
          "ctrl+l=goto_split:right"
        ];
        copy-on-select = "clipboard";
        shell-integration = "zsh";
      };
    };  # https://ghostty.org/
  };
}
