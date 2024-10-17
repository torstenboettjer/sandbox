{
  description = "Default Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      # system = builtins.currentSystem;
      system = "_SYSTEM_";
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations = {
        torsten = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };
      };
    };
}
