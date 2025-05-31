# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  monitorsXmlContent = builtins.readFile /home/torsten/.config/monitors.xml;
  # monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/powersave.nix
    ];

  hardware.firmware = [
    pkgs.linux-firmware
  ];
  hardware.enableAllFirmware=true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=3
    options i915 enable_dpcd_backlight=1
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lindar"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Set trusted users
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # needed for store VS Code auth token
  services.gnome.gnome-keyring.enable = true;

  # Monitor settings for entry screen
  #systemd.tmpfiles.rules = [
    #"L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  #];

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Supported internationalisation properties.
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" "nl_NL.UTF-8/UTF-8"];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
    LANG = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "de-latin1-nodeadkeys";

  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:bvn*:bvr*:bd*:svnGoogle:pnLindar:pvr*
      KEYBOARD_KEY_DB=rightmeta
      KEYBOARD_KEY_01=esc
      KEYBOARD_KEY_EA=back
      KEYBOARD_KEY_E9=forward
      KEYBOARD_KEY_E7=refresh
      KEYBOARD_KEY_91=f11
      KEYBOARD_KEY_92=print
      KEYBOARD_KEY_94=brightnessdown
      KEYBOARD_KEY_95=brightnessup
      KEYBOARD_KEY_A0=mute
      KEYBOARD_KEY_AE=volumedown
      KEYBOARD_KEY_B0=volumeup
  '';

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        meta = {
          back = "f1";
          forward = "f2";
          refresh = "f3";
          f11 = "f4";
          print = "f5";
          brightnessdown = "f6";
          brightnessup = "f7";
          mute = "f8";
          volumedown = "f9";
          volumeup = "f10";
        };
      };
    };
  };

  # Enable keyd service according to https://github.com/NixOS/nixpkgs/issues/290161
  systemd.services.keyd.serviceConfig.CapabilityBoundingSet = [
    "CAP_SETGID"
  ];

  # Preserve display manager configuration at restart
  systemd.services.display-manager.restartIfChanged = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.torsten = {
    isNormalUser = true;
    description = "Torsten Boettjer";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    home-manager
    alsa-utils
    pavucontrol
    direnv
  ];

  # Install firefox.
  programs.firefox.enable = true;

  # Enable captive browser for public WiFi login
  programs.captive-browser = {
    enable = true;
    interface = "wlp0s20f3";
  };

  # Use zsh
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      edit = "sudo -e";
      update = "sudo nixos-rebuild switch";
      # Keep the history for searchability
      histFile = "/etc/nixos/history";
    };
  };

  programs.zsh.interactiveShellInit = ''eval "$(direnv hook zsh)"'';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
