{ config, pkgs, lib, ... }:

let
  username = "torsten";
  homedir = "/home/${username}";
in

{
  home.stateVersion = "24.11"; # Please read the comment before changing.
  home = {
    username = username;
    homeDirectory = homedir;
  };

  targets.genericLinux.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Import base modules
  imports = [
    ./modules/services/github.nix
    ./modules/system/nixos.nix
  ];

  # Set the backup file extension
  home-manager.backupFileExtension = "backup";

  # The home.packages section installs Nix packages.
  home.packages = with pkgs; [
    devenv       # https://devenv.sh/
    gnumake      # https://www.gnu.org/software/make/manual/make.html
    tgpt         # https://github.com/aandrew-me/tgpt
    lunarvim     # https://www.lunarvim.org/
  ];

  # The home.programs section installs home-manager modules.
  programs = {
    home-manager.enable = true;
    direnv = { # https://direnv.net/
      enable = true;
      enableZshIntegration = true;
    };
    jq.enable = true;     # https://jqlang.github.io/jq/
    fzf = { # https://github.com/junegunn/fzf
      enable = true;
      enableZshIntegration = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/torsten/etc/profile.d/hm-session-vars.sh
  #
}
