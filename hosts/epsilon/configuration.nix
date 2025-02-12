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
  modules.nix-cache = {
    enable = true;
    signingKeySecretFile = config.sops.secrets.nix_priv.path;
    cacheHostName = "nix.epsilon.tquelch.com" ;
  };
}
