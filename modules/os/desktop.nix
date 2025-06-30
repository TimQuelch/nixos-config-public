{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.modules.os.desktop;
in
{
  options.modules.os.desktop = {
    enable = lib.mkEnableOption "gui and audio config";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    qt.enable = true;
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    security.pam.services.hyprlock = { };
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
