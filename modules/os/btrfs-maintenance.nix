{ config, lib, pkgs, ... }:
let
  cfg = config.modules.btrfs-maintenance;

  escapeSystemdPath = path:
    lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" path);

  mkMountPointServices = mountPoint: {
    "btrfs-balance-${escapeSystemdPath mountPoint}" = {
      description = "BTRFS Balance Service for ${mountPoint}";
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          "${pkgs.btrfs-progs}/bin/btrfs balance start -dusage=${toString cfg.balanceStartThreshold} -musage=${toString cfg.balanceStartThreshold} ${mountPoint}";
        Nice = 19;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
        CPUSchedulingPolicy = "idle";
        CPUWeight = 10;
        ConditionACPower = true;
      };
    };

    "btrfs-scrub-${escapeSystemdPath mountPoint}" = {
      description = "BTRFS Scrub Service for ${mountPoint}";
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          "${pkgs.btrfs-progs}/bin/btrfs scrub start -B ${mountPoint}";
        Nice = 19;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
        CPUSchedulingPolicy = "idle";
        CPUWeight = 10;
        ConditionACPower = true;
      };
    };
  };

  mkMountPointTimers = mountPoint: {
    "btrfs-balance-${escapeSystemdPath mountPoint}" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.balanceInterval;
        Persistent = true;
      };
    };

    "btrfs-scrub-${escapeSystemdPath mountPoint}" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.scrubInterval;
        Persistent = true;
      };
    };
  };

in {
  options.modules.btrfs-maintenance = {
    enable = lib.mkEnableOption "Automated BTRFS maintenance";

    balanceInterval = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      description = "How often to run BTRFS balance. Uses systemd calendar syntax.";
    };

    balanceStartThreshold = lib.mkOption {
      type = lib.types.int;
      default = 50;
      description = "Usage percentage at which to start balance";
    };

    scrubInterval = lib.mkOption {
      type = lib.types.str;
      default = "monthly";
      description = "How often to run BTRFS scrub. Uses systemd calendar syntax.";
    };

    mountPoints = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of BTRFS mount points to maintain";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.mkMerge (map mkMountPointServices cfg.mountPoints);
    systemd.timers = lib.mkMerge (map mkMountPointTimers cfg.mountPoints);
  };
}
