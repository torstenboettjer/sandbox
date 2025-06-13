{ config, pkgs, inputs, lib, ... }:

{
  programs = {
    zed-editor = {
      enable = true;
      #package = pkgs.zed-editor;
      extensions = [
        "rainbow-csv"
        "sql"
        "gemini"
        "git-firefly"
        "nix"
        "graphql"
        "python"
        "rust"
        "xy-zed"
        "make"
        "prettier"
        "yaml"
        "toml"
      ];
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
          dark = "Catppuccin Macchiato";
        };
        features = {
          copilot = true;
          # inline_completion_provider = "supermaven";
          inline_completion_provider = "copilot";
        };
        telemetry = {
          metrics = false;
        };
        vim_mode = false;
        assistant = {
          enabled = true;
          enable_experimental_live_diffs = true;
          default_open_ai_model = null;
          ### PROVIDER OPTIONS
          ### zed.dev models { claude-3-5-sonnet-latest } requires github connected
          ### anthropic models { claude-3-5-sonnet-latest claude-3-haiku-latest claude-3-opus-latest  } requires API_KEY
          ### copilot_chat models { gpt-4o gpt-4 gpt-3.5-turbo o1-preview } requires github connected
          default_model = {
            provider = "Mistral";
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
        context_servers = {
          postgres-context-server = {
            settings = {
                database_url = "postgresql://torsten:mypassword@localhost:5432/rescile";
            };
          };
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
  };
}
