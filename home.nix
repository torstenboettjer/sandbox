{ config, pkgs, lib, ... }:
let
  homedir = "/home/_USRNAME_";
  username = "_USRNAME_";
  gituser = "_GHUSER_";
  gitemail = "_GHEMAIL_";
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
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    devenv       # https://devenv.sh/
    gnumake      # https://www.gnu.org/software/make/manual/make.html
    # lunarvim   # https://www.lunarvim.org/
    # zed-editor # https://zed.dev/

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'mysbx' to your
    # # environment:
    (writeShellScriptBin "mysbx" ''
      # Create the new remote repository on GitHub
      gh repo create "${gituser}/mysbx" --private

      # Check if the repository was created successfully
      if [ $? -ne 0 ]; then
          echo "Failed to create the remote repository on GitHub."
          exit 1
      fi

      # Unlink the local repository from the current origin
      mv ${homedir}/sandbox ${homedir}/mysbx && cd ${homedir}/mysbx && git remote remove origin

      # Link the local repository with the new remote repository
      git remote add origin "https://github.com/${gituser}/mysbx.git"

      # Push the new branch to the new remote repository
      git push "https://github.com/${gituser}/mysbx.git" "main"

      # Check if the branch was pushed successfully
      if [ $? -ne 0 ]; then
          echo "Failed to push the local repository to GitHub."
          exit 1
      fi

      # Verify the new remote setup
      git remote -v

      echo "The sandbox directory has been successfully linked to your remote repository."
      echo "Remote repository: https://github.com/${gituser}/mysbx.git"
    '')
  ];

  programs = {
    direnv.enable = true; # https://direnv.net/
    vscode = {
      enable = true; # https://code.visualstudio.com/
      package = pkgs.vscode;
      enableUpdateCheck = false;
    };
    jq.enable = true;     # https://jqlang.github.io/jq/
    fzf.enable = true;    # https://github.com/junegunn/fzf
    gh.enable = true;     # https://cli.github.com/manual/
  };

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
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Configure git
  programs = {
    git = {
      enable = true;
      userName = gituser;
      userEmail = gitemail;
    };

    # uncomment the following lines to use nix-direnv (handle with care, the original .bashrc will be replaced with a symbolic link)
    # direnv = {
    #   enable = true;
    #   enableBashIntegration = true; # see note on other shells below
    #   nix-direnv.enable = true;
    # };

    # bash.enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
