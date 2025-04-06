{
  lib,
  config,
  pkgs,
  options,
  ...
}:
let
  cfg = config.modules.email;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.modules.email = {
    enable = mkEnableOption "email";
  };

  config = mkIf cfg.enable {
    sops.secrets.fastmail_token = { };

    accounts.email.maildirBasePath = "maildir";
    accounts.email.accounts.personal = {
      primary = true;
      address = "tim@tquelch.com";
      realName = "Tim Quelch";
      flavor = "fastmail.com";
      passwordCommand = "cat ${config.sops.secrets.fastmail_token.path}";
      notmuch.enable = true;
      mujmap.enable = true;
    };

    programs.notmuch.enable = true;
    programs.mujmap.enable = true;

    systemd.user.services.mujmap-sync = {
      Unit.Description = "Sync maildir with mujmap";
      Service = {
        Type = "exec";
        WorkingDirectory = "${config.accounts.email.maildirBasePath}/personal";
        ExecStart = "${lib.getExe config.programs.mujmap.package} sync -v";
      };
    };

    systemd.user.timers.mujmap-sync = {
      Unit.Description = "Sync maildir with mujmap";
      Timer = {
        OnStartupSec = "3min";
        OnUnitInactiveSec = "30min";
      };
      Install.WantedBy = [ "timers.target" ];
    };

    systemd.user.services.notmuch-compact = {
      Unit.Description = "Compact notmuch database";
      Service = {
        Type = "exec";
        ExecStart = "${lib.getExe pkgs.notmuch} compact";
        Nice = 19;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
        CPUSchedulingPolicy = "idle";
        CPUWeight = "idle";
      };
    };

    systemd.user.timers.notmuch-compact = {
      Unit.Description = "Sync maildir with mujmap";
      Timer = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
