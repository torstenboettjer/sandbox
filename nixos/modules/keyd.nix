{ config, lib, pkgs, ... }:

{
  services.keyd = {
    enable = true;
    keyboards = {
        # The name is just the name of the configuration file, it does not really matter
        default = {
            ids = [ "*" ]; # what goes into the [id] section, here we select all keyboards
            # Everything but the ID section:
            settings = {
                main = {
                    Super_L = "layer(Super_L)";
                };
                Super_L = {
                    h = "left";
                    l = "right";
                    k = "up";
                    j = "down";
                    u = "prior";
                    i = "home";
                    o = "end";
                    p = "next";
                };
            };
        };
    };
  };
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';
}
