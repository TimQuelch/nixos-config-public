{ pkgs, ... }:
{
  home.packages = with pkgs; [
    firefox
    wofi
    polkit-kde-agent
    xwaylandvideobridge
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "waybar"
    ];
    "$mod" = "SUPER";
    bind = [
      # Control
      "$mod, Q, killactive"
      "$mod, H, movefocus, l"
      "$mod, L, movefocus, r"
      "$mod, J, movefocus, d"
      "$mod, K, movefocus, u"

      # not sure what this is
      "$mod, S, togglespecialworkspace, magic"
      "$mod SHIFT, S, movetoworkspace, special:magic"

      # Programs
      "$mod, F, exec, firefox"
      "$mod, R, exec, wofi --show drun"
      "$mod, T, exec, kitty"
    ]
    ++ (
      builtins.concatLists (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 5;
          in
            builtins.toString (x + 1 - (c * 5));
        in [
          "$mod, ${ws}, workspace, ${toString (x + 1)}"
          "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
        ]
      )
      5)
    );
    bindm = [
      # LMB to move, RMB to resize
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
    windowrulev2 = [
      "opacity 0.0 override, class:^(xwaylandvideobridge)$"
      "noanim, class:^(xwaylandvideobridge)$"
      "noinitialfocus, class:^(xwaylandvideobridge)$"
      "maxsize 1 1, class:^(xwaylandvideobridge)$"
      "noblur, class:^(xwaylandvideobridge)$"
    ];
  };

  programs.waybar.enable = true;
  programs.hyprlock.enable = true;

  # services. hyprpaper.enable = true;
  # services.hypridle.enable = true;
  services.mako.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs  .xdg-desktop-portal-hyprland ];
}
