{ lib, config, pkgs, user, rebuild, ... }: {
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
      firefox
      chromium
      git
      vim
      ripgrep
      fd
      jq
      tree
      kitty
      htop
      fzf
      bitwarden
      iosevka
      yubikey-manager
      duf
      dust
      ncdu
      magic-wormhole
      sqlite
      julia
      dbeaver-bin
      magic-wormhole
      zoom-us
      pwvucontrol
      discord
    ];
    sessionVariables = { EDITOR = "vim"; };
  };
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;

  modules.git.enable = lib.mkDefault true;
  modules.shell.zsh.enable = lib.mkDefault true;
  modules.shell.direnv.enable = lib.mkDefault true;
  modules.ssh.enable = lib.mkDefault true;
  modules.emacs.enable = lib.mkDefault true;

  # Should be overwritten in host specific configs
  home.stateVersion = lib.mkDefault "24.05";
}