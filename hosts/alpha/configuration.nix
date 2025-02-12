{ config, lib, pkgs, ... }: {
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
  };

  services.libinput.mouse.accelProfile = "flat";

  services.xserver.videoDrivers = [ "nvidia" ];

  networking.wireless.iwd = {
    enable = true;
    settings.Settings.AutoConnect = true;
  };
  networking.wireless.userControlled.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  services.ollama = {
    enable = true;
    acceleration = "cuda";
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
      "nix.alpha.tquelch.com" = {
        locations."/".proxyPass =
          "http://${config.services.nix-serve.bindAddress}:${
            toString config.services.nix-serve.port
          }";
      };
    };
  };
}
