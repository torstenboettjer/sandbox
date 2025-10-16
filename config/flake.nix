{
  description = "Centralized Home Manager Configuration and User Profiles";

  inputs = {
    # 1. Pin Nixpkgs (Used for building the user environments)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 2. Pin Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # 3. Add any other useful inputs (like the Claude Desktop flake)
    #    Since this is the centralized place for all user apps.
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    username = "torsten"; # Define the primary user globally

    # Map of all your Home Manager profiles
    homeProfiles = {
      default = ./profiles/default.nix;
      consult = ./profiles/consult.nix;
      analyst = ./profiles/analyst.nix;
    };

    # Function to create a Home Manager configuration for a specific user and profile
    mkHomeConfiguration = profilePath: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      # Define the target user (which must exist on the system)
      modules = [
        # The specific profile module
        profilePath
        # Pass inputs/outputs as special arguments, needed by modules like claude-desktop
        {
          home.username = username;
          home.homeDirectory = "/home/${username}";
          home.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };

  in {
    # 💡 The primary output: Named Home Manager configurations
    homeConfigurations = nixpkgs.lib.mapAttrs'
      (profileName: profilePath: {
        # The name of the configuration will be 'torsten-default', 'torsten-consult', etc.
        name = "${username}-${profileName}";
        value = mkHomeConfiguration profilePath;
      })
      homeProfiles;

    # 💡 Optional: Define reusable modules to be imported by devShells
    #    We are making the 'default' profile available as a reusable module for direnv
    homeManagerModules.default = ./profiles/default.nix;
    homeManagerModules.analyst = ./profiles/analyst.nix;
    # (The contents of this module will be merged into a devShell's mkShell)
  };
}
