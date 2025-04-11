{ config, pkgs, lib, ... }:
let
  username = "torsten";
  homedir = "/home/${username}";
  gituser = "torstenboettjer";
  gitorg = "rescile";
  gitemail = "torsten.boettjer@gmail.com";
in
{
  # On Generic Linux (non NixOS)
  targets.genericLinux.enable = true;

  # Enable the configuration to allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = username;
    homeDirectory = homedir;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Set the backup file extension
  # home-manager.backupFileExtension = "backup";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    devenv       # https://devenv.sh/
    gnumake      # https://www.gnu.org/software/make/manual/make.html
    tgpt         # https://github.com/aandrew-me/tgpt
    lunarvim     # https://www.lunarvim.org/
  ];

  programs = {
    home-manager.enable = true; # Let home-manager install and manage itself
    direnv = { # https://direnv.net/
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
    };
    git = {
      enable = true;
      userName = gituser;
      userEmail = gitemail;
    };
    jq.enable = true;     # https://jqlang.github.io/jq/
    fzf = { # https://github.com/junegunn/fzf
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    gh.enable = true;     # https://cli.github.com/manual/
    vscode = {
      enable = true; # https://code.visualstudio.com/.visualstudio.com/
      package = pkgs.vscode-fhs;
      profiles.default.enableUpdateCheck = false;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        emroussel.atomize-atom-one-dark-theme
        yzhang.markdown-all-in-one
        redhat.vscode-yaml
        ritwickdey.liveserver
        ms-vscode.makefile-tools
        jnoortheen.nix-ide
        esbenp.prettier-vscode
        rust-lang.rust-analyzer
        fill-labs.dependi
        njpwerner.autodocstring
        continue.continue
        mechatroner.rainbow-csv
      ];
      # Settings
      profiles.default.userSettings = {
        # General
        "window.titleBarStyle" = "custom";
        "workbench.colorTheme" = "Atomize";
        "terminal.integrated.defaultProfile.linux" = "zsh";
        "git.autofetch" = true;
        "autoDocstring.docstringFormat" = "google";
        "dependi.go.enabled" = true;
        "dependi.rust.enabled" = true;
        "dependi.python.enabled" = true;
        "liveServer.settings.port" = 5500;
        "nix.enableLanguageServer" = false;
        };
    };
    bash.enable = true;
  };

  #nixpkgs.config = {
  #  allowUnfree = true;
    # Workaround for https://github.com/nix-community/home-manager/issues/2942
  #  allowUnfreePredicate = _: true;
  #};
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
