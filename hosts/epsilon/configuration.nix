{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Settings = {
        AutoConnect = true;
      };
    };
  };
  networking.useDHCP = true;
  networking.wireless.userControlled.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
}
