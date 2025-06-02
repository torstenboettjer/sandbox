{ lib, config, pkgs, ... }:

{
  powerManagement = {
    enable = true;
    #powertaop.enable = false;
    #cpuFreqGovernor = lib.mkDefault "powersave";
  };
  #systemd.tmpfiles.rules = [
  #  "w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"
  #];

  services.logind = {
    lidSwitch = "lock";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "lock";
    powerKey = "ignore";
    extraConfig = ''
      #IdleAction=hybrid-sleep
      #IdleAction=suspend-then-hibernate
      #IdleActionSec=30min
      #IdleAction=lock
      #IdleActionSec=480
      #HandlePowerKey=ignore
      HandlePowerKeyLongPress=halt
      #LidSwitchIgnoreInhibited=no
    '';
  };

  services.thermald.enable = true;
  services.tlp.enable = lib.mkForce false;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        energy_performance_preference = "balance_performance";
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        energy_performance_preference = "balance_power";
        turbo = "auto";
      };
    };
  };
  services.power-profiles-daemon.enable = lib.mkForce (if config.services.auto-cpufreq.enable then false else true);
  #services.throttled.enable = true;
  services.fstrim.enable = true;

  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.laptop_mode" = 5;
    "vm.swappiness" = 20;
    "kernel.nmi_watchdog" = 0;
  };
  boot.kernelParams = [
    #"usbcore.autosuspend=5"
    #"usbcore.autosuspend=-1"
    "pcie_aspm.policy=powersupersave"
  ];
  #boot.extraModulePackages = with config.boot.kernelPackages; [ phc-intel ];

  environment.systemPackages = with pkgs; [
    powertop
    powercap
  ];

  #boot.extraModprobeConfig = ''
  #  options snd_hda_intel power_save=1
  #'';
  #boot.blacklistedKernelModules = [
  #  "snd_hda_codec_hdmi"
  #];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="${pkgs.iw}/bin/iw dev $name set power_save on"
    #ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", GOTO="power_usb_rules_end"
    #ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    #LABEL="power_usb_rules_end"
    #SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0xa0c8", ATTR{power/control}="on", GOTO="pci_pm_end"
    #SUBSYSTEM=="pci", ATTR{power/control}="auto"
    #LABEL="pci_pm_end"
    ACTION=="add", SUBSYSTEM=="usb", ENV{SYSTEMD_WANTS}+="powertopauto.service", TAG+="systemd"
    #SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="1", ENV{SYSTEMD_WANTS}+="intel-rapl-balanced.service", TAG+="systemd"
    #SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="0", ENV{SYSTEMD_WANTS}+="intel-rapl-powersave.service", TAG+="systemd"
  '';

  #systemd.services.lidevent = {
  #  enable = true;
  #  description = "LID event tunner";
  #  after = [ "suspend.target" ];
  #  wantedBy = [ "multi-user.target" ];
  #  serviceConfig = {
  #    Type = "simple";
  #    SyslogIdentifier = "lidevent";
  #    Restart = "always";
  #    RestartSec = 30;
  #  };
  #  script = ''
  #    ${pkgs.coreutils}/bin/stdbuf -oL ${pkgs.libinput}/bin/libinput debug-events | ${pkgs.gnugrep}/bin/egrep --line-buffered '^.event[0-9]+\s+SWITCH_TOGGLE\s' | while read line; do
  #      if grep -Fq "^stat:.*closed$" /proc/acpi/button/lid/LID0/state; then
  #        echo 0 | ${pkgs.coreutils}/bin/tee /sys/bus/usb/devices/3-9/authorized
  #      else
  #        echo 1 | ${pkgs.coreutils}/bin/tee /sys/bus/usb/devices/3-9/authorized
  #        #systemctl restart fprintd.service
  #      fi
  #    done
  #  '';
  #};

  systemd.services.intel-rapl-balanced = {
    enable = true;
    description = "Set Intel RAPL power limits (balanced)";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    conflicts = [ "intel-rapl-powersave.service" "thermald.service" ];
    #wantedBy = [ "multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    #wantedBy = [ "sysinit.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/sh -c '${pkgs.powercap}/bin/powercap-set intel-rapl -z 0 -c 0 -l 18000000 -s 10000000 && ${pkgs.powercap}/bin/powercap-set intel-rapl -z 0 -c 2 -l 36000000'";
      ExecStop = "${pkgs.bash}/bin/sh -c '${pkgs.powercap}/bin/powercap-set intel-rapl -z 0 -c 0 -l 200000000 && ${pkgs.powercap}/bin/powercap-set intel-rapl -z 0 -c 2 -l 121000000'";
      RemainAfterExit = true;
    };
  };
  systemd.services.intel-rapl-powersave = {
    enable = true;
    description = "Set Intel RAPL power limits (powersave)";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    conflicts = [ "intel-rapl-balanced.service" "thermald.service" ];
    #wantedBy = [ "sysinit.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/sh -c '${pkgs.powercap}/bin/powercap-set intel-rapl -z 0 -c 0 -l 12000000 -s 10000000 && ${pkgs.powercap}/bin/powercap-set intel-rapl -z 0 -c 2 -l 18000000'";
      ExecStop = "${pkgs.bash}/bin/sh -c '${pkgs.powercap}/bin/powercap-set intel-rapl -z 0 -c 0 -l 200000000 && ${pkgs.powercap}/bin/powercap-set intel-rapl -z 0 -c 2 -l 121000000'";
      RemainAfterExit = true;
    };
  };

  systemd.services.powertopauto = {
    description = "Powertop tunings";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    wantedBy = [ "multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    script = ''
      ${pkgs.powertop}/bin/powertop --auto-tune
      HIDDEVICES=$(${pkgs.coreutils}/bin/ls /sys/bus/usb/drivers/usbhid 2> /dev/null | ${pkgs.gnugrep}/bin/grep -oE '^[0-9]+-[0-9\.]+' | ${pkgs.coreutils}/bin/sort -u)
      for i in $HIDDEVICES; do
        echo -n "Enabling " | ${pkgs.coreutils}/bin/cat - /sys/bus/usb/devices/$i/product
        echo 'on' > /sys/bus/usb/devices/$i/power/control
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
