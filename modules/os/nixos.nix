{
  config,
  pkgs,
  lib,
  user,
  ...
}:
{
  system.stateVersion = lib.mkDefault "25.05";

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  time.timeZone = "Australia/Melbourne";
  i18n.defaultLocale = "en_AU.UTF-8";

  sops.secrets.user_password.neededForUsers = true;
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.user_password.path;
    shell = pkgs.zsh;
  };
}
