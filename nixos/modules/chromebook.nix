{ config, lib, pkgs, ... }:
let
  #gnome-randr-rust = (pkgs.callPackage /home/jens/Code/nix/nixconfig/packages/gnome-randr-rust/default.nix {});
  chromebook-linux-audio = pkgs.stdenvNoCC.mkDerivation {
    name = "chromebook-linux-audio";
    version = "0-unstable-2024-11-25";
    src = pkgs.fetchFromGitHub {
      owner = "WeirdTreeThing";
      repo = "chromebook-linux-audio";
      rev = "ae2f8cf30a26806376cc8591af4a66d33a763ef4";
      hash = "sha256-lc5nHLhybyp8b2x9QvwO6YXOSmuDjBe9CJNEswZIIvM=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/firmware/intel/avs
      tar xf blobs/avs-topology_2024.02.tar.gz
      cp -R avs-topology/lib/firmware/intel/avs/* $out/lib/firmware/intel/avs/
      # cp -R conf/avs/tplg/* $out/lib/firmware/intel/avs/
      rm -f $out/lib/firmware/intel/avs/max98357a-tplg.bin
      runHook postInstall
    '';

    dontBuild = true;
    dontFixup = true;
  };
  alsa-ucm-conf-cros = pkgs.alsa-ucm-conf.overrideAttrs {
    wttsrc = pkgs.fetchFromGitHub {
      owner = "WeirdTreeThing";
      repo = "alsa-ucm-conf-cros";
      rev = "5b4253786ac0594a6ae9fe06336b54d8bc66efb0";
      hash = "sha256-CeZtEA2Wq0zle/3OHbob2GDH4ffczGqZ2qVItKME5eI=";
    };
    postInstall = ''
      cp -R $wttsrc/ucm2/* $out/share/alsa/ucm2
      cp -R $wttsrc/overrides/* $out/share/alsa/ucm2/conf.d
    '';
  };
in
{

  environment = {
    sessionVariables.ALSA_CONFIG_UCM2 = "${alsa-ucm-conf-cros}/share/alsa/ucm2";
  };
  hardware.firmware = [
      chromebook-linux-audio
      pkgs.sof-firmware
  ];

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-avs-dmic.conf" ''
      monitor.alsa.rules = [
        {
          matches = [
            {
              node.nick = "Internal Microphone"
            }
          ]
          actions = {
            update-props = {
              audio.format = "S16LE"
            }
          }
        }
      ]
    '')
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-headphone.conf" ''
      monitor.alsa.rules = [
        {
          matches = [
            {
              node.nick = "Headphones"
            }
          ]
          actions = {
            update-props = {
              audio.format = "S16LE"
            }
          }
        }
      ]
    '')
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-increase-headroom.conf" ''
      monitor.alsa.rules = [
        {
          matches = [
            {
              node.name = "~alsa_output.*"
            }
          ]
          actions = {
            update-props = {
              api.alsa.period-size = 256
              api.alsa.headroom = 8192
            }
          }
        }
      ]
    '')
  ];

  services.fwupd.enable = true;

  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=1
    #options snd-soc-avs ignore_fw_version=1
    options i915 enable_dpcd_backlight=1
  '';

  # Keyboard
  # Special keyboard mapping for Eve project. The keyboard has extra
  # "Assistant" and "Hamburger" keys.
  # https://github.com/systemd/systemd/blob/main/hwdb.d/60-keyboard.hwdb
  #services.udev.extraHwdb = ''
  #  evdev:atkbd:dmi:bvn*:bvr*:bd*:svnGoogle:pnEve:pvr*
  #    KEYBOARD_KEY_5d=menu
  #    KEYBOARD_KEY_d8=rightmeta
  #    KEYBOARD_KEY_db=capslock
  #    KEYBOARD_KEY_3b=back
  #    KEYBOARD_KEY_3c=f5
  #    KEYBOARD_KEY_3d=f11
  #    KEYBOARD_KEY_3e=print
  #    KEYBOARD_KEY_3f=brightnessdown
  #    KEYBOARD_KEY_40=brightnessup
  #    KEYBOARD_KEY_41=playpause
  #    KEYBOARD_KEY_42=mute
  #    KEYBOARD_KEY_43=volumedown
  #    KEYBOARD_KEY_44=volumeup

    # I: Bus=0005 Vendor=3175 Product=9100 Version=0001
    # N: Name="Brydge C-Type v1.4 Keyboard"
    # I: Bus=0003 Vendor=3175 Product=9100 Version=0111
    # N: Name="Brydge Brydge C-Type v1.4"
  #  evdev:input:b0005v3175p9100*
  #  evdev:input:b0003v3175p9100*
  #    KEYBOARD_KEY_c019f=menu
  #    KEYBOARD_KEY_ffd10018=rightmeta
  #    KEYBOARD_KEY_700e3=capslock
  #    KEYBOARD_KEY_7003a=back
  #    KEYBOARD_KEY_7003b=f5
  #    KEYBOARD_KEY_7003c=f11
  #    KEYBOARD_KEY_7003d=print
  #    KEYBOARD_KEY_7003e=brightnessdown
  #    KEYBOARD_KEY_7003f=brightnessup
  #    KEYBOARD_KEY_70040=playpause
  #    KEYBOARD_KEY_70041=mute
  #    KEYBOARD_KEY_70042=volumedown
  #    KEYBOARD_KEY_70043=volumeup

    # I: Bus=0003 Vendor=3175 Product=9100 Version=0111
    # N: Name="Brydge Brydge C-Type v1.4"
    # evdev:input:b0003v3175p9100*
    #   KEYBOARD_KEY_ffd10018=rightmeta

    # evdev:name:Brydge Brydge C-Type v1.4:dmi:bvn*:bvr*:bd*:svn*:pn*:pvr*
    #   KEYBOARD_KEY_ffd10018=rightmeta

  #  sensor:modalias:platform:cros-ec-accel:dmi:bvncoreboot:bvrMrChromebox-*:*:*:efr0.0:svnGoogle:pnEve*:*
  #    ACCEL_MOUNT_MATRIX=-1, 0, 0; 0, -1, 0; 0, 0, -1
  #'';


  #environment.etc."libinput/local-overrides.quirks".text = ''
  #  [keyd virtual keyboard]
  #  MatchName=keyd virtual keyboard
  #  AttrKeyboardIntegration=internal
  #  ModelTabletModeNoSuspend=1
  #'';

  #services.keyd = {
  #  enable = true;
  #  keyboards.pixelbook = {
  #    ids = [
  #      "k:0001:0001"
  #      "k:18d1:5044"
  #      "k:18d1:5052"
  #      "k:0000:0000"
  #      "k:18d1:5050"
  #      "k:18d1:504c"
  #      "k:18d1:503c"
  #      "k:18d1:5030"
  #      "k:18d1:503d"
  #      "k:18d1:505b"
  #      "k:18d1:5057"
  #      "k:18d1:502b"
  #      "k:18d1:5061"
  #      "k:3175:9100"
  #    ];
  #    settings = {
  #      main = {
  #        capslock = "leftmouse";
  #      };
  #      leftshift = {
  #        leftmouse = "rightmouse";
  #      };
  #      meta = {
  #        back = "f1";
  #        f5 = "f2";
  #        f11 = "f3";
  #        print = "f4";
  #        brightnessdown = "f5";
  #        brightnessup = "f6";
  #        playpause = "f7";
  #        mute = "f8";
  #        volumedown = "f9";
  #        volumeup = "f10";
  #        menu = "f11";
  #        };
  #      alt = {
  #        backspace = "delete";
  #        up = "pageup";
  #        down = "pagedown";
  #        brightnessdown = "kbdillumdown";
  #        brightnessup = "kbdillumup";
  #      };
  #      controlalt = {
  #        menu = "C-A-delete";
  #      };
  #    };
  #  };
  #};
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.sensor.iio.enable = true;
}
