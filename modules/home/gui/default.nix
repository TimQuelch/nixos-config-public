{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.modules.gui;
in
{
  imports = [
    ./hyprland.nix
    ./packages.nix
    ./ghostty.nix
  ];

  options.modules.gui.enable = lib.mkEnableOption "gui configuration";

  config = lib.mkIf cfg.enable {
    modules.gui.hyprland.enable = true;
    modules.gui.packages.enable = true;
    modules.gui.ghostty.enable = true;
  };
}
