{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.libinput.mouse.accelProfile = "flat";

  networking.wireless.iwd = {
    enable = true;
    settings.Settings.AutoConnect = true;
  };
  networking.wireless.userControlled.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  services.ollama = {
    enable = false;
    acceleration = "cuda";
  };
}
