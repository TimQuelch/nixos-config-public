{
  lib,
  config,
  pkgs,
  ...
}:
{
  modules.gui.enable = true;
  modules.email.enable = true;
  modules.latex.enable = true;

  services.hypridle.enable = lib.mkForce false;
}
