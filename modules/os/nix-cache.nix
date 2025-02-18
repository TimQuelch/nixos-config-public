{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nix-cache;
in
{
  options.modules.nix-cache = {
    enable = lib.mkEnableOption "nix store binary cache";
  };

  config = lib.mkIf cfg.enable {

    sops.secrets.nix-cache-jwt.sopsFile = ../../secrets/nix-cache.yaml;

    sops.templates.nix-cache-netrc.content = ''
      machine nix.theta.tquelch.com
      password ${config.sops.placeholder.nix-cache-jwt}
    '';

    environment.etc."attic/config.toml".text = ''
      default-server = "theta"

      [servers.theta]
      endpoint = "https://nix.theta.tquelch.com"
      token-file = "${config.sops.secrets.nix-cache-jwt.path}"
    '';

    nix.settings = {
      substituters = [ "https://nix.theta.tquelch.com/theta" ];
      trusted-public-keys = [ "theta:bEYWsk8RIf6epx3nKxVjn+hWWOFyX6rlOqBLqBUBTOw=" ];
      netrc-file = config.sops.templates.nix-cache-netrc.path;
    };

    systemd.services.attic-nix-cache-upload = {
      environment.XDG_CONFIG_HOME = "/etc";
      script = ''
        ${lib.getExe pkgs.attic-client} push theta /run/current-system
        ${lib.getExe pkgs.attic-client} watch-store theta
      '';
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Restart = "on-failure";
        Nice = 19;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
        CPUSchedulingPolicy = "idle";
        CPUWeight = 10;
      };
    };
  };
}
