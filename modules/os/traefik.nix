{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.traefik;
in
{
  options.modules.traefik = {
    enable = lib.mkEnableOption "traefik";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 ];

    services.traefik = {
      enable = true;

      staticConfigOptions = {
        entryPoints = {
          web = {
            address = ":80";
            asDefault = true;
          };
        };
      };
    };
  };
}
