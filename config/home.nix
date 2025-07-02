{
  lib,
  config,
  pkgs,
  user,
  rebuild,
  ...
}:
{
  # Setup secrets
  sops = {
    defaultSopsFile = ../secrets/user-secrets.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/sops-nix.txt";
    age.generateKey = true;
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    packages = with pkgs; [
      rebuild # rebuild nixos/homemanger config
      git
      vim
      ripgrep
      fd
      jq
      yq
      tree
      htop
      fzf
      iosevka
      yubikey-manager
      duf
      dust
      ncdu
      magic-wormhole
      sqlite
      julia
      magic-wormhole
      gh
      sshfs
      just
      zip
      unzip
    ];
  };
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;

}
