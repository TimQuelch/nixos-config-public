{ config, lib, pkgs, ... }:
{
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
  };

  services.libinput.mouse.accelProfile = "flat";

  services.xserver.videoDrivers = ["nvidia"];

  networking.wireless.iwd = {
    enable = true;
    settings = {
      Settings = {
        AutoConnect = true;
      };
    };
  };
  networking.wireless.userControlled.enable = true;

  # programs.steam = {
  #   enable = true;
  #   extraCompatPackages = [ pkgs.proton-ge-bin ];
  # };

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05";
}
