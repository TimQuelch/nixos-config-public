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
    enable = lib.mkEnableOption "nix store as binary cache";
    signingKeySecretFile = lib.mkOption { type = lib.types.str; };
    cacheHostName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 ];

    services.nix-serve = {
      enable = true;
      secretKeyFile = cfg.signingKeySecretFile;
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        ${cfg.cacheHostName} = {
          locations."/".proxyPass =
            "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
        };
      };
    };
  };
}
