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
      rebuild                   # rebuild nixos/homemanger config
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

  programs.git = {
    enable = true;
    userEmail = "tim@tquelch.com";
    userName = "Tim Quelch";
    aliases = { graph = "log --oneline --all --decorate --graph"; };
    extraConfig = {
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      merge = { ff = false; };
      pull = { ff = "only"; };
      init = { defaultBranch = "main"; };
      # url = {
      #   "ssh://git@github.com:" = {
      #     insteadOf = "https://github.com/";
      #   };
      # };
    };
    delta.enable = true;
  };

  programs.nix-index.enable = true;

  modules.shell.zsh.enable = true;
  modules.shell.direnv.enable = true;
  modules.ssh.enable = true;
  modules.emacs.enable = true;


  # Should be overwritten in host specific configs
  home.stateVersion = lib.mkDefault "24.05";
}
