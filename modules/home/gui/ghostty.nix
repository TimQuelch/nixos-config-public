{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.gui.ghostty;
in
{
  options.modules.gui.ghostty.enable = lib.mkEnableOption "ghostty";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ghostty ];

    modules.gui.hyprland.terminal = "${pkgs.ghostty}/share/applications/com.mitchellh.ghostty.desktop";

    xdg.configFile."ghostty/config".text = ''
      window-decoration=false
      gtk-single-instance=true
    '';
  };
}
