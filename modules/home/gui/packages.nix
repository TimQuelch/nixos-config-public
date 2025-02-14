{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.gui.packages;
in
{
  options.modules.gui.packages = {
    enable = lib.mkEnableOption "gui packages";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      firefox
      chromium
      bitwarden
      zoom-us
      pwvucontrol
      discord
    ];
  };
}
