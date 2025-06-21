{ config, lib, pkgs, ... }:

{
  boot.loader.grub = {
    enable = true;
    efiSupport = true;

    # Replace "/dev/nvme0n1" with the actual path to your boot disk (e.g., /dev/sda)
    devices = [ "/dev/nvme0n1" ];
    # Replace "1920x1080" with the resolution you found in step 1.
    # You can also add ",auto" to let GRUB try to automatically select the best mode if yours doesn't work.
    # For example: "1920x1080,auto"
    gfxmodeEfi = "1920x1200,auto"; # For UEFI systems

    # This keeps the graphics mode set by GRUB for the kernel's early boot stage.
    # It helps prevent a flicker or resolution change after GRUB.
    gfxpayloadEfi = "keep"; # For UEFI systems

    # You might also want to set a font if the default is too small even at a higher resolution
    # font = "${pkgs.unifont}/share/fonts/unifont/unifont.ttf"; # Example using unifont
    # fontSize = 16; # Adjust as needed
  };
}
