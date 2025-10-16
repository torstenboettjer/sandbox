{ config, pkgs, inputs, ... }:

{
  # 💡 Required: Set the state version
  home.stateVersion = "24.05"; # Use the same version as your system flake

  # 💡 Consistent application packages for all profiles
  home.packages = with pkgs; [
    # Basic command-line tools
    tmux
    git
    ripgrep
    fd
    wget

    # Application from an imported flake (using extraSpecialArgs from flake.nix)
    inputs.claude-desktop.packages.${pkgs.system}.default
  ];

  # 💡 Consistent program configuration
  programs.zsh = {
    enable = true;
    shellAliases = {
      update = "home-manager switch --flake ~/dotfiles#torsten-default";
      hl = "history | grep"; # Example alias
    };
  };

  # 💡 Optional: Terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      # ... your shared alacritty settings here ...
    };
  };
}
