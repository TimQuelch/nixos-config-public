{ lib, config, pkgs, system, ... }: {
  modules.gui.enable = true;
  modules.email.enable = true;

  services.hypridle.enable = lib.mkForce false;
}
