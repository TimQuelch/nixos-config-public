{
  lib,
  options,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.gui.hyprland;
  defaultTerminal = "ghostty";
  nWorkspaces = 10;
  compress-png = pkgs.writeShellApplication {
    name = "compress-png";
    runtimeInputs = [ pkgs.pngquant ];
    text = ''
      tmpFile="$(mktemp)"
      pngquant "$1" --force --output "$tmpFile"
      mv "$tmpFile" "$1"
    '';
  };
  screenshotScripts =
    map
      (
        mode:
        pkgs.writeShellApplication {
          name = "screenshot-${mode}";
          runtimeInputs =
            (with pkgs; [
              hyprshot
              swappy
            ])
            ++ [ compress-png ];
          text = ''
            hyprshot --mode=${mode} --freeze --clipboard-only --raw | swappy -f - && false
            fd --changed-within 5s . "${config.xdg.userDirs.pictures}" -x compress-png {}
          '';
        }
      )
      [
        "window"
        "region"
      ];
in
{

  options.modules.gui.hyprland = {
    enable = lib.mkEnableOption "hyprland config";
    terminal = lib.mkOption {
      type = lib.types.str;
      default = defaultTerminal;
      description = "Terminal to use with hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false; # Disabled because this conflicts with nixos's uwsm integration
    };

    home.packages =
      (with pkgs; [
        wofi
        hyprpolkitagent
        kdePackages.xwaylandvideobridge
        nwg-displays
        wl-clipboard
        hyprswitch
        brightnessctl
      ])
      ++ screenshotScripts;

    home.activation.hyprpolkitagent =
      lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
        ''run ${config.systemd.user.systemctlPath} --user enable hyprpolkitagent.service'';

    wayland.windowManager.hyprland.settings = {
      # Run some commands as  systemd transient serivces so we get logs in journal
      exec-once = [
        "waybar"
        "systemd-run --user --wait ${pkgs.custom.hyprland-scripting}/bin/hyprland-listener"
        "systemd-run --user --wait hyprswitch init"
      ];
      "$mod" = "SUPER";
      bind =
        [
          # Control
          "$mod, Q, killactive"
          "$mod, V, togglefloating"
          "$mod, P, pseudo"
          "$mod, J, togglesplit"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"

          "$mod, TAB, exec, uwsm app -- hyprswitch gui --mod-key super_l --key tab --close mod-key-release --switch-type workspace && hyprswitch dispatch"

          # Special workspace
          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"

          # Screenshots
          "$mod, PRINT, exec, uwsm app -- screenshot-region"
          "$mod SHIFT, PRINT, exec, uwsm app -- screenshot-window"

          # Programs
          "$mod, C, exec, uwsm app -- firefox"
          "$mod, R, exec, uwsm app -- $(wofi --show drun --define=drun-print_desktop_file=true)"
          "$mod, RETURN, exec, uwsm app -- ${cfg.terminal}"
          "$mod, T, exec, uwsm app -- ${cfg.terminal}"

          # fn keys
          ", XF86MonBrightnessUp, exec, uwsm app -- brightnessctl set '+15%'"
          ", XF86MonBrightnessDown, exec, uwsm app -- brightnessctl set '15%-'"
        ]
        ++ (builtins.concatLists (
          builtins.genList (
            x:
            let
              ws =
                let
                  c = (x + 1) / nWorkspaces;
                in
                builtins.toString (x + 1 - (c * nWorkspaces));
            in
            [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          ) nWorkspaces
        ));
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
      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
      };
    };

    programs.waybar.enable = true;
    programs.waybar.settings.mainBar = {
      height = 30;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "network"
        "cpu"
        "memory"
        "battery"
        "tray"
      ];
      network = {
        format-wifi = "{ifname}: {essid} ({signalStrength}%) ";
        format-ethernet = "{ifname}: {ipaddr}/{cidr} 󰈁";
        format-linked = "{ifname} (No IP) 󰈂";
        format-disconnected = "Disconnected";
      };
      cpu = {
        format = "CPU {usage}%";
        tooltip = false;
      };
      memory = {
        format = "Mem {}%";
        tooltip = false;
      };
      battery = {
        states = {
          good = 95;
          warning = 30;
          critical = 15;
        };
        format = "Bat {capacity}%";
        format-charging = "Bat {capacity}%";
        format-plugged = "Bat {capacity}%";
        format-alt = "{time}";
      };
      clock = {
        format = "{:%a %Y-%m-%d %H:%M}";
      };
    };
    programs.waybar.style = ./waybar.css;

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          grace = 10;
        };
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

    xdg.configFile."swappy/config".text = ''
      [Default]
      save_dir=${config.xdg.userDirs.pictures}
      save_filename_format=screenshot-%Y%m%d-%H%M%S.png
      early_exit=true
    '';
  };
}
