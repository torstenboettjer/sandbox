{ config, lib, pkgs, ... }:

{
  services = {
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      # Configure keymap in X11
      xkb = {
        layout = "de";
        variant = "nodeadkeys";
      };
    };
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # Some applications like
    # VS Code auth token form the gnome keyring
    gnome.gnome-keyring.enable = true;
  };
}
