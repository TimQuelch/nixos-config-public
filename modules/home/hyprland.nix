{ pkgs, config, ... }:
let
  nWorkspaces = 10;
in {
  home.packages = with pkgs; [
    firefox
    wofi
    polkit-kde-agent
    xwaylandvideobridge
    nwg-displays
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "waybar"
    ];
    "$mod" = "SUPER";
    bind = [
      # Control
      "$mod, Q, killactive"
      "$mod, V, togglefloating"
      "$mod, P, pseudo"
      "$mod, J, togglesplit"
      "$mod, H, movefocus, l"
      "$mod, L, movefocus, r"
      "$mod, J, movefocus, d"
      "$mod, K, movefocus, u"

      # not sure what this is
      "$mod, S, togglespecialworkspace, magic"
      "$mod SHIFT, S, movetoworkspace, special:magic"

      # Programs
      "$mod, C, exec, firefox"
      "$mod, R, exec, wofi --show drun"
      "$mod, RETURN, exec, kitty"
      "$mod, T, exec, kitty"
    ]
    ++ (
      builtins.concatLists (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / nWorkspaces;
          in
            builtins.toString (x + 1 - (c * nWorkspaces));
        in [
          "$mod, ${ws}, workspace, ${toString (x + 1)}"
          "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
        ]
      )
      nWorkspaces)
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
    xwayland = {
      force_zero_scaling = true;
    };
    source = "${config.xdg.configHome}/hypr/monitors.conf";
    animation = [
      "windows, 1, 2, default, popin"
      "workspaces, 1, 3, default, slide"
      "specialWorkspace, 1, 2, default, slidefadevert"
    ];
  };

  programs.waybar.enable = true;
  programs.waybar.settings.mainBar = {
    height = 40;
    font-size = "16px";
    modules-left = [ "hyprland/workspaces" ];
    modules-center = [ "hyprland/window" ];
    modules-right = [
      "network"
      "cpu"
      "memory"
      "battery"
      "clock"
      "tray"
    ];
    network = {
      format-wifi = "{essid} ({signalStrength}%) ";
      format-ethernet = "{ipaddr}/{cidr} 󰈁";
      format-linked = "{ifname} (No IP) 󰈂";
      format-disconnected = "Disconnected 󰀦";
    };
    cpu = {
      format = "{usage}% ";
      tooltip = false;
    };
    memory = {
      format = "{}% ";
      tooltip = false;
    };
    battery = {
      states = {
        good = 95;
        warning = 30;
        critical = 15;
      };
      format = "{capacity}% {icon}";
      format-alt = "{time} {icon}";
      format-good = "";
      format-full = "";
      format-icons = ["" "" "" "" ""];
    };
    clock = {
      format = "{:%a %Y-%m-%d %H:%M %Z}";
    };
    "hyprland/workspaces" = {
      format = "{icon} {windows}";
      window-rewrite-default = "";
      window-rewrite = {
        "class<firefox>" = "";
        "kitty" = "";
        "code" = "󰨞";
        "emacs" = "";
      };
    };
    "hyprland/window" = {
      rewrite = {
        "(.*) — Mozilla Firefox" = " $1";
        "(.*) – Doom Emacs" = " $1";
      };
    };
  };
  programs.waybar.style = ''
    * {
      font-size: 18px;
    }
  '';

  programs.hyprlock.enable = true;

  # services. hyprpaper.enable = true;
  # services.hypridle.enable = true;
  services.mako.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs  .xdg-desktop-portal-hyprland ];
}
