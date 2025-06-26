{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/netboot/netboot-minimal.nix") ];

  system.stateVersion = config.system.nixos.release;

  documentation.man.enable = lib.mkForce false;
  documentation.doc.enable = lib.mkForce false;

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
  ];

}
