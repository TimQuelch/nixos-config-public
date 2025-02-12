{ config, lib, pkgs, ... }: {
  networking.wireless.iwd = {
    enable = true;
    settings = { Settings = { AutoConnect = true; }; };
  };
  networking.useDHCP = true;
  networking.wireless.userControlled.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  sops.secrets.nix_priv.sopsFile = ./secrets.yaml;
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.sops.secrets.nix_priv.path;
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "nix.epsilon.tquelch.com" = {
        locations."/".proxyPass =
          "http://${config.services.nix-serve.bindAddress}:${
            toString config.services.nix-serve.port
          }";
      };
    };
  };
}
