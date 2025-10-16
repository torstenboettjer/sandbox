{
  description = "Isolated Development Shell for Data Analysis Project";

  inputs = {
    # Nixpkgs: Pin a specific,stable version of Nixpkgs for project reproducibility
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    # User Flake: Import your central Home Manager configuration
    # (This pulls in zsh, direnv settings, tgpt, lunarvim, and psql client tools)
    user-home = {
      url = "path:~/.config";
      # Ensure it uses the same base nixpkgs for compatibility
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 3. Utility for easier shell definition
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, user-home, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Import the specific analyst profile module from your user flake
        analystHomeModule = user-home.homeManagerModules.analyst;
      in
      {
        # Define the development shell
        devShells.default = pkgs.mkShell {
          # Define project-specific dependencies (e.g., Python environment)
          packages = with pkgs; [
            # A Python environment tailored for data work
            (python3.withPackages (p: with p; [
              pandas
              numpy
              scikit-learn
              # postgresql client tools are inherited from the analyst profile
            ]))
            git
            sqlite # Local database for quick testing
          ];

          # Import the shared user configurations and project-specific services
          # This merges all modules into the shell environment.
          imports = [
            analystHomeModule
            ./services.nix # <-- Imports the Metabase/JRE configuration from the Canvas
          ];

          # Project setup logic that runs when entering the shell
          # The shellHook from ./services.nix will be merged with this one.
          shellHook = ''
            echo "Entering Data Analyst Dev Environment"
            echo "Current Python: $(which python)"
          '';
        };
      }
    );
}
