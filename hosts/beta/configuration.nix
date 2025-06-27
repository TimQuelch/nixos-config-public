{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./disks.nix ];

  services.server.enable = lib.mkForce false;
  services.displayManager.sddm.enable = lib.mkForce false;
  programs.hyprland.enable = lib.mkForce false;
  qt.enable = lib.mkForce false;
  services.pipewire.enable = lib.mkForce false;
}
