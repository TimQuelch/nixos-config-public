{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.podman-compose
  ];

  virtualisation = {
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
