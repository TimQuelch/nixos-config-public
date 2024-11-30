{ pkgs, config, inputs, system, ... }:
let
  nWorkspaces = 10;
  hyprland-scripting = pkgs.callPackage ../../packages/hyprland-scripting { };
  compress-png = pkgs.writeShellApplication {
    name = "compress-png";
    runtimeInputs = [ pkgs.pngquant ];
    text = ''
      tmpFile="$(mktemp)"
      pngquant "$1" --force --output "$tmpFile"
      mv "$tmpFile" "$1"
    '';
  };
  screenshotScripts = map (mode:
    pkgs.writeShellApplication {
      name = "screenshot-${mode}";
      runtimeInputs = (with pkgs; [ hyprshot swappy ]) ++ [ compress-png ];
      text = ''
        hyprshot --mode=${mode} --freeze --clipboard-only --raw | swappy -f - && false
        fd --changed-within 5s . "${config.xdg.userDirs.pictures}" -x compress-png {}
      '';
    }) [ "window" "region" ];
in {
  home.packages = (with pkgs; [
    firefox
    wofi
    polkit-kde-agent
    xwaylandvideobridge
    nwg-displays
    wl-clipboard
    inputs.hyprswitch.packages.${system}.default
  ]) ++ screenshotScripts;

  wayland.windowManager.hyprland.settings = {
    # Run some commands as  systemd transient serivces so we get logs in journal
    exec-once = [
      "waybar"
      "systemd-run --user --wait ${hyprland-scripting}/bin/hyprland-listener"
      "systemd-run --user --wait hyprswitch init"
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

      "$mod, TAB, exec, hyprswitch gui --mod-key super_l --key tab --close mod-key-release --switch-type workspace && hyprswitch dispatch"

      # Special workspace
      "$mod, S, togglespecialworkspace, magic"
      "$mod SHIFT, S, movetoworkspace, special:magic"

      # Screenshots
      "$mod, PRINT, exec, screenshot-region"
      "$mod SHIFT, PRINT, exec, screenshot-window"

      # Programs
      "$mod, C, exec, firefox"
      "$mod, R, exec, wofi --show drun"
      "$mod, RETURN, exec, kitty"
      "$mod, T, exec, kitty"
    ] ++ (builtins.concatLists (builtins.genList (x:
      let ws = let c = (x + 1) / nWorkspaces; in builtins.toString (x + 1 - (c * nWorkspaces));
      in [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]) nWorkspaces));
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
    xwayland = { force_zero_scaling = true; };
    source = "${config.xdg.configHome}/hypr/monitors.conf";
    animation = [
      "windows, 1, 2, default, popin"
      "workspaces, 1, 3, default, slide"
      "specialWorkspace, 1, 2, default, slidefadevert"
    ];
    misc = {
      disable_splash_rendering = true;
      disable_hyprland_logo = true;
    };
  };

  programs.waybar.enable = true;
  programs.waybar.settings.mainBar = {
    height = 40;
    font-size = "16px";
    modules-left = [ "hyprland/workspaces" ];
    modules-center = [ "hyprland/window" ];
    modules-right = [ "network" "cpu" "memory" "battery" "clock" "tray" ];
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
      format-icons = [ "" "" "" "" "" ];
    };
    clock = { format = "{:%a %Y-%m-%d %H:%M %Z}"; };
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

  programs.hyprlock = {
    enable = true;
    settings = {
      general = { grace = 10; };
      background = {
        path = "screenshot";
        blur_passes = 2;
        blur_size = 5;
      };
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = "${./wallpapers/iceberg.jpeg}";
      wallpaper = ",${./wallpapers/iceberg.jpeg}";
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # services.hypridle.enable = true;
  services.mako.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  xdg.portal.configPackages = [ pkgs.xdg-desktop-portal-hyprland ];

  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=${config.xdg.userDirs.pictures}
    save_filename_format=screenshot-%Y%m%d-%H%M%S.png
    early_exit=true
  '';
}
