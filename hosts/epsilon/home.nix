{ config, pkgs, system, ... }:
{
  wayland.windowManager.hyprland.enable = true;

  home.stateVersion = "24.05";
}
