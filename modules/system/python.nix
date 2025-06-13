{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Python with specific packages
    (python314.withPackages (ps: with ps; [
      requests
      uv
      # torch
      # Add more Python packages here
    ]))

    # Optional: Additional tools (e.g., pipx, Jupyter)
    pipx
  ];
}
