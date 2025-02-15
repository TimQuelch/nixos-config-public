{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nix-cache;
  traefikHttp = config.services.traefik.dynamicConfigOptions.http;
in
{
  options.modules.nix-cache = {
    enable = lib.mkEnableOption "nix store as binary cache";
    signingKeySecretFile = lib.mkOption { type = lib.types.str; };
    cacheHostName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.nix-serve = {
      enable = true;
      secretKeyFile = cfg.signingKeySecretFile;
    };

    services.traefik.dynamicConfigOptions.http.routers.nix-serve = {
      rule = "Host(`${cfg.cacheHostName}`)";
      service = "nix-serve";
    };
    services.traefik.dynamicConfigOptions.http.services.nix-serve.loadBalancer.servers = [
      { url = "http://localhost:${toString config.services.nix-serve.port}"; }
    ];
  };
}
