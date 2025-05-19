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

  # Configure nix in user config as well as root so that we have user-level garbage collection. This
  # ensures old home manager profiles are cleaned up
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 7d";
    };
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
    sessionVariables = {
      EDITOR = "vim";
    };
  };
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;

  modules.git.enable = lib.mkDefault true;
  modules.shell.zsh.enable = lib.mkDefault true;
  modules.shell.direnv.enable = lib.mkDefault true;
  modules.ssh.enable = lib.mkDefault true;
  modules.emacs.enable = lib.mkDefault true;
  modules.dirs.enable = lib.mkDefault true;
  modules.aider.enable = lib.mkDefault true;
  modules.nix-shell-helper.enable = lib.mkDefault true;
  modules.cloud.aws = lib.mkDefault true;
  modules.cloud.azure = lib.mkDefault true;

  # Should be overwritten in host specific configs
  home.stateVersion = lib.mkDefault "25.05";
}
