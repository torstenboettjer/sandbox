{ config, pkgs, ... }:

{
  # 💡 This is the main service composition file for the project environment.
  # It imports specific service modules (like Metabase) to keep the
  # environment flexible and composable.
  imports = [
    # Import the dedicated Metabase service module
    ./modules/metabase.nix
    # Future services (e.g., ./modules/redis.nix, ./modules/rabbitmq.nix)
    # can be added here easily.
  ];
}
