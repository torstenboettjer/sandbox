{ pkgs, ... }:
let
  username = "torsten";
  homedir = "/home/${username}";
  gituser = "torstenboettjer";
  #gitorg = "rescile";
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
    nixd # https://github.com/nix-community/nixd.git
    tgpt # https://github.com/aandrew-me/tgpt
    lunarvim   # https://www.lunarvim.org/
    gdrive3    # https://github.com/glotlabs/gdrive

    # Gonme extensions
    gnomeExtensions.arcmenu
    gnomeExtensions.bluetooth-quick-connect
    gnomeExtensions.clipboard-history
    gnomeExtensions.dash-to-dock
    gnomeExtensions.gsconnect
    gnomeExtensions.lan-ip-address
    gnomeExtensions.printers
    gnomeExtensions.vitals
    gnomeExtensions.desktop-icons-ng-ding

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'mysbx' to your
    # # environment:
  ];
  programs = {
    direnv = { # https://direnv.net/
        enable = true;
        enableBashIntegration = true; # see note on other shells below
        nix-direnv.enable = true;
    };
    git = {
      enable = true;
      userName = gituser;
      userEmail = gitemail;
    };
    jq.enable = true;     # https://jqlang.github.io/jq/
    fzf.enable = true;    # https://github.com/junegunn/fzf
    gh.enable = true;     # https://cli.github.com/manual/
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
      };
    };  # https://ghostty.org/
    chromium = {
      enable = true;
      package = pkgs.google-chrome;
    };
    zed-editor = {
      enable = true;
      #package = pkgs.zed-editor;
      extensions = [ "rainbow-csv" "sql" "gemini" "nix" "graphql" "python" "rust" "xy-zed" "make" "marksman" "yaml"];
      userKeymaps = [{
        context = "Workspace";
        bindings = {
          ctrl-shift-t = "workspace::NewTerminal";
        };
      }];
      userSettings = {
        theme = {
            mode = "dark";
            light = "Catppuccin Latte";
            dark = "Catppuccin Mocha";
        };
        features = {
          copilot = false;
          inline_completion_provider = "supermaven";
        };
        telemetry = {
          metrics = false;
        };
        vim_mode = false;
        assistant = {
            enabled = true;
            version = "2";
            default_open_ai_model = null;
            ### PROVIDER OPTIONS
            ### zed.dev models { claude-3-5-sonnet-latest } requires github connected
            ### anthropic models { claude-3-5-sonnet-latest claude-3-haiku-latest claude-3-opus-latest  } requires API_KEY
            ### copilot_chat models { gpt-4o gpt-4 gpt-3.5-turbo o1-preview } requires github connected
            default_model = {
                provider = "zed.dev";
                model = "claude-3-5-sonnet-latest";
            };

            # inline_alternatives = [
            #   {
            #     provider = "copilot_chat";
            #     model = "gpt-3.5-turbo";
            #   }
            # ];
        };
        inlay_hints = {
          enabled = true;
          show_type_hints = true;
          show_parameter_hints = true;
          show_other_hints = true;
        };
        # lsp = {
        #   rust-analyzer = {
        #     binary = {
        #       path = "{pkgs.rust-analyzer}/bin/rust-analyzer";
        #     };
        #     initialization_options = {
        #       inlayHints = {
        #         maxLength = null;
        #         lifetimeElisionHints = {
        #           enable = "skip_trivial";
        #           useParameterNames = true;
        #         };
        #         closureReturnTypeHints = {
        #           enable = "always";
        #         };
        #       };
        #     };
        #   };
        # };
        ui_font_family = "Arimo";
        ui_font_size = 16;
        buffer_font_size = 16;
      };
    };
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
    bash.enable = true;
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        pkgs.gnomeExtensions.arcmenu.extensionUuid
        pkgs.gnomeExtensions.bluetooth-quick-connect.extensionUuid
        pkgs.gnomeExtensions.clipboard-history.extensionUuid
        pkgs.gnomeExtensions.dash-to-dock.extensionUuid
        pkgs.gnomeExtensions.gsconnect.extensionUuid
        pkgs.gnomeExtensions.lan-ip-address.extensionUuid
        pkgs.gnomeExtensions.printers.extensionUuid
        pkgs.gnomeExtensions.vitals.extensionUuid
      ];
    };
    "org/gnome/desktop/peripherals/mouse" = {
        natural-scroll = false;
        speed = -0.5;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
    };
    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      clock-show-weekday = true;
      enable-animations = false;
    };
    "org/gnome/system/location" = {
      enabled = true;
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };
    "org/gtk/settings/file-chooser" = {
      clock-format = "24h";
    };
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
