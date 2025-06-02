{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
  ];

  # Enable Sound with PipeWire
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;             # Disable Pulseaudio if it's enabled
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
    wireplumber.enable = true;
  };

  # Persist ALSA support
  hardware.alsa.enablePersistence = true;
}
