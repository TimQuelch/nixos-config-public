{
  config,
  hostname,
  ...
}:
{
  networking.hostName = hostname;
  networking.firewall.enable = true;
  services.resolved.enable = true;

  sops.secrets.tailscale_auth_key = { };
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
    authKeyFile = config.sops.secrets.tailscale_auth_key.path;
    extraUpFlags = [
      "--accept-dns"
      "--accept-routes"
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
