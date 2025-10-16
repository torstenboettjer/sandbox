// /etc/nixos/flake.nix (Rewritten System Flake)

{
  description = "Host OS Base System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Optional: Add your shared user flake input if you plan to manage
    # the base user setup (like installing the direnv user tool) here.
    # The intended method is a separate dedicated user flake.
    # user-flake.url = "path:~/.config";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
  in {
    # Define a single core host configuration
    nixosConfigurations.devserver = nixpkgs.lib.nixosSystem {
      system = system;
      modules = [
        # Import the core system configuration file
        ./configuration.nix

        # Optional: Add a module to enable direnv globally here
        ({ config, pkgs, ... }: {
            programs.direnv = {
                enable = true;
                enableFlakes = true;
            };
        })
      ];
    };
  };
}
