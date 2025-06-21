{ lib, config, pkgs, ... }:

{
  powerManagement = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    powertop
    powercap
  ];

  services.logind = {
    lidSwitch = "suspend"; # Suspend when lid is closed (on battery or AC)
    lidSwitchDocked = "ignore"; # Do nothing if docked (e.g., using external monitor)
    lidSwitchExternalPower = "suspend"; # Suspend when lid closed, even on AC
    powerKey = "suspend"; # Suspend on a short power button press
    extraConfig = ''
      # Optional: Lock the screen after a period of inactivity
      IdleAction=lock
      IdleActionSec=300 # Lock after 5 minutes (300 seconds)

      # Optional: More aggressive idle actions (uncomment one if desired)
      # IdleAction=hybrid-sleep
      # IdleAction=suspend-then-hibernate

      HandlePowerKeyLongPress=poweroff # Shut down on a long power button press (BIOS often handles this too)
      # LidSwitchIgnoreInhibited=no # This is the default and usually desired for laptops
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

  # Kernel parameters related to virtual leptop memory management and system behavior
  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.laptop_mode" = 5;
    "vm.swappiness" = 20;
    "kernel.nmi_watchdog" = 0;
  };

  boot.kernelParams = [
    "pcie_aspm.policy=powersupersave"
  ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="${pkgs.iw}/bin/iw dev $name set power_save on"
    ACTION=="add", SUBSYSTEM=="usb", ENV{SYSTEMD_WANTS}+="powertopauto.service", TAG+="systemd"
  '';
}
