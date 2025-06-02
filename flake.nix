{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";  # ✅ Add this
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, claude-desktop, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.lindar = nixpkgs.lib.nixosSystem {
      system = system;
      modules = [
        ./configuration.nix
        # ./modules/python-env.nix  # Import my Python module
        home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.users.torsten = import ./home.nix;

          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
        }
      ];
    };

    packages.x86_64-linux.hello = pkgs.hello;
    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
  };
}
