{ config, pkgs, lib, ... }:
let
  username = "torsten";
  homedir = "/home/${username}";
  projectdir = "${homedir}/ditio";
  gituser = "torstenboettjer";
  gitorg = "ditiocloud";
  projecttpl = "${gituser}/template";
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
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Set the backup file extension
  # home-manager.backupFileExtension = "backup";

  # Import external Nix files
  imports = ["${homedir}/.config/home-manager/tools/captivebrowser.nix"];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    devenv       # https://devenv.sh/
    gnumake      # https://www.gnu.org/software/make/manual/make.html
    element-desktop-wayland   # https://element.io/
    nixd # https://github.com/nix-community/nixd.git
    tgpt # https://github.com/aandrew-me/tgpt
    # lunarvim   # https://www.lunarvim.org/
    # zed-editor # https://zed-editor.org/

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
    (writeShellScriptBin "project" ''
      # capture the project name with a first argument
      PROJECTNAME=$1

      # check whether the project directory already exists locally
      if [ -d ${projectdir}/$PROJECTNAME ]; then
          echo "Project directory already exists! Attempting to clone ..."
      else
        # create projects directory if it doesn't exist
        mkdir -p ${projectdir} && cd ${projectdir}
      fi

      # Check whether sync repo already exist
      if [ $(gh api repos/${gitorg}/$PROJECTNAME --silent --include 2>&1 | grep -Eo 'HTTP/[0-9\.]+ [0-9]{3}' | awk '{print $2}') -eq 200 ]; then
        echo "cloning the existing $PROJECTNAME project ..."

        # Clone the project repository with gh
        gh repo clone ${gitorg}/$PROJECTNAME ${projectdir}/$PROJECTNAME
      else
        #create a new repository from a template

        echo "Creating the $PROJECTNAME project from template ${projecttpl} ..."

        # Clone the project template repository with gh
        gh repo clone ${projecttpl} ${projectdir}/$PROJECTNAME

        # Create the new remote repository on GitHub
        gh repo create "${gitorg}/$PROJECTNAME" --private

        # Check if the repository was created successfully
        if [ $? -ne 0 ]; then
            echo "Failed to create the remote repository on GitHub."
            exit 1
        fi

        # unlink the template remote repository
        cd ${projectdir}/$PROJECTNAME && git remote remove origin

        # Add "${gitorg}/$PROJECTNAME" as new remote repository
        cd ${projectdir}/$PROJECTNAME && git remote add origin "https://github.com/${gitorg}/$PROJECTNAME.git" && git push --set-upstream origin main
      fi

      # Verify the new remote setup
      cd ${projectdir}/$PROJECTNAME && git remote -v

      echo "Remote repository: https://github.com/${gitorg}/$PROJECTNAME.git"
    '')
  ];

  xdg.desktopEntries.element-desktop-wayland = {
      name = "element-desktop-wayland";
      genericName = "Matrix Client";
      exec = "element-desktop -- %u";
      terminal = false;
      icon = "element-desktop";
  };

  xdg.desktopEntries.foot = {
      name = "foot";
      genericName = "Terminal";
      exec = "foot -- %u";
      terminal = false;
      icon = "foot";
  };

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
    chromium = {
      enable = true;
      package = pkgs.google-chrome;
    };
    foot = {
        enable = true;
        package = pkgs.foot;
        settings = { # Examples: https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
          main = {
            # shell=$SHELL (if set, otherwise user's default shell from /etc/passwd)
            term = "foot";
            app-id = "foot"; # globally set wayland app-id. Default values are "foot" and "footclient" for desktop and server mode
            title = "foot";
            locked-title = "no";
            font = "monospace:size=11";
            # font=monospace:size=8
            # font-bold = <bold variant of regular font>
            # font-italic = <italic variant of regular font>
            # font-bold-italic = <bold+italic variant of regular font>
            # font-size-adjustment = 0.5
            # line-height = <font metrics>
            # letter-spacing = 0
            # horizontal-letter-offset = 0
            # vertical-letter-offset = 0
            # underline-offset = <font metrics>
            # underline-thickness = <font underline thickness>
            # strikeout-thickness = <font strikeout thickness>
            # box-drawings-uses-font-glyphs = "no"
            # dpi-aware = "no"

            initial-window-size-pixels = "1920x1536";
            # initial-window-size-chars=<COLSxROWS>
            initial-window-mode= "windowed";
            pad = "5x5";   # optionally append 'center'
            resize-by-cells = "yes";
            # resize-keep-grid = "yes";
            # resize-delay-ms=100

            # bold-text-in-bright=no
            # word-delimiters=,│`|:"'()[]{}<>
          };

          environment = {
            name = "NixOS";
          };

          cursor = {
            color = "111111 cccccc";
          };

          colors = {
            #alpha = 1.0;
            #background = "282c34";
            #foreground = "9da39d";
            #flash = "90b061";
            #flash-alpha = 0.5;
            foreground = "979eab";
            background = "282c34";
            regular0 = "282c34";   # black
            regular1 = "e06c75";   # red
            regular2 = "98c379";   # green
            regular3 = "e5c07b";   # yellow
            regular4 = "61afef";   # blue
            regular5 = "be5046";   # magenta
            regular6 = "56b6c2";   # cyan
            regular7 = "979eab";   # white
            bright0 = "393e48";    # bright black
            bright1 = "d19a66";    # bright red
            bright2 = "56b6c2";    # bright green
            bright3 = "e5c07b";    # bright yellow
            bright4 = "61afef";    # bright blue
            bright5 = "be5046";    # bright magenta
            bright6 = "56b6c2";    # bright cyan
            bright7 = "abb2bf";    # bright white
            # selection-foreground = "282c34";
            # selection-background = "979eab";
          };

          scrollback = {
          lines = 1000;
          # multiplier=3.0;
          indicator-position = "relative";
          # indicator-format="";
          };

          mouse = {
            hide-when-typing = "yes";
          };

          csd = {
            # preferred=server
            size = 26;
            font = "monspace";
            color = "32363e";
            hide-when-maximized = "no";
            double-click-to-maximize = "yes";
            border-width = 1;
            border-color = "5c6370";
            button-width = 26;
            button-color = "abb2bf";
            button-minimize-color = "292d34";
            button-maximize-color = "292d34";
            button-close-color = "c678dd";
          };
        };
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
        features = {
          copilot = false;
          inline_completion_provider = "supermaven";
        };
        telemetry = {
          metrics = false;
        };
        vim_mode = false;
        assistant = {
          default_model = {
            provider = "openai";
            model = "gpt-4o";
          };
          version = "2";
          default_open_ai_model = null;
          provider = {
            name = "openai";
            default_model = "gpt-3.5-turbo";
          };
        };
        inlay_hints = {
          enabled = true;
          show_type_hints = true;
          show_parameter_hints = true;
          show_other_hints = true;
        };
        lsp = {
          rust-analyzer = {
            binary = {
              path = "{pkgs.rust-analyzer}/bin/rust-analyzer";
            };
            initialization_options = {
              inlayHints = {
                maxLength = null;
                lifetimeElisionHints = {
                  enable = "skip_trivial";
                  useParameterNames = true;
                };
                closureReturnTypeHints = {
                  enable = "always";
                };
              };
            };
          };
        };
        ui_font_size = 16;
        buffer_font_size = 16;
      };
    };
    vscode = {
      enable = true; # https://code.visualstudio.com/.visualstudio.com/
      package = pkgs.vscode-fhs;
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
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
        continue.continue
      ];
      # Settings
      userSettings = {
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

  home.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # For using VS Code and Brave under Wayland
    };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
