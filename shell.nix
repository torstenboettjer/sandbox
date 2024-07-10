{ pkgs ? import <nixpkgs> {}, ... }:

let
  home-manager = import <home-manager> {};
in
pkgs.mkShell {
  buildInputs = [
    # pkgs.zsh
    # pkgs.python3
  ];

  shellHook = ''
    echo "Operator environment!"
  '';

  # Example home-manager configuration
  homeConfigurations = {
    user = {
      home.packages = with pkgs; [
        lunarvim # https://www.lunarvim.org/
        fzf
      ];

      # programs.zsh.enable = true;
    };
  };
}
