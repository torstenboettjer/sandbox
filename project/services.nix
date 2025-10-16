{ config, pkgs, serviceModulesPath, ... }:

{
  # This is the main service composition file for the project environment.
  # It now imports modules from the centralized dotfiles directory.
  imports = [
    # Use string interpolation to reference the module in the modules location
    "${serviceModulesPath}/metabase.nix"
    # Future services (e.g., "${serviceModulesPath}/redis.nix")
    # can be added here easily.
  ];
}
