{
  description = "Centralized Home Manager Configuration and User Profiles";

  inputs = {
    # Pin Nixpkgs (Used for building the user environments)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Pin Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Add any other useful inputs (like the Claude Desktop flake)
    # Since this is the centralized place for all user apps.
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

    # Calculate portable HOME directory path
    homeDir = builtins.getEnv "HOME";

    # Define portable paths to your centralized modules
    programModulesPath = "${homeDir}/.config/modules/programs";
    serviceModulesPath = "${homeDir}/.config/modules/services";

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
        # Pass inputs/outputs and the new module paths as special arguments
        {
          home.username = username;
          home.homeDirectory = "/home/${username}"; # This should typically be set by the system flake or determined by home-manager, but we keep it here for clarity.

          home.extraSpecialArgs = {
            inherit inputs programModulesPath serviceModulesPath; # 💡 Pass the calculated paths
          };
        }
      ];
    };

  in {
    # The primary output: Named Home Manager configurations
    homeConfigurations = nixpkgs.lib.mapAttrs'
      (profileName: profilePath: {
        # The name of the configuration will be 'torsten-default', 'torsten-consult', etc.
        name = "${username}-${profileName}";
        value = mkHomeConfiguration profilePath;
      })
      homeProfiles;

    # Optional: Define reusable modules to be imported by devShells
    # Note: These modules (the files in ./profiles) will automatically receive
    # the 'programModulesPath' and 'serviceModulesPath' when imported into a devShell
    # because the devShell is responsible for passing these as 'extraSpecialArgs'.
    homeManagerModules.default = ./profiles/default.nix;
    homeManagerModules.analyst = ./profiles/analyst.nix;
  };
}
