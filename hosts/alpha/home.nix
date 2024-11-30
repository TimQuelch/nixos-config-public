{ config, pkgs, system, ... }: {
  wayland.windowManager.hyprland.enable = true;

  modules.email.enable = true;
}
