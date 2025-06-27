{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ ../modules/os/nix-cache-key.nix ];

  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGMYzCjPfXiK69yH31OtrAwnx1c+6NpuXsIi1VolFV4WAAAAC3NzaDplbmNyeXB0 ssh:encrypt"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgGBjXWjSghvdItYBgKA4hBZNaniRLWbc4r0p2esSK5 non_sk"
  ];
}
