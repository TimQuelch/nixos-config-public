{ config, pkgs, user, ... }:
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
      firefox
      git
      vim
      ripgrep
      fd
      jq
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
    ];
    sessionVariables = {
      EDITOR = "vim";
    };
  };
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userEmail = "tim@tquelch.com";
    userName = "Tim Quelch";
    aliases = {
      graph = "log --oneline --all --decorate --graph";
    };
    extraConfig = {
      push = {
        default =  "current";
        autoSetupRemote = true;
      };
      merge = {
        ff = false;
      };
      pull = {
        ff = "only";
      };
      init = {
        defaultBranch = "main";
      };
      # url = {
      #   "ssh://git@github.com:" = {
      #     insteadOf = "https://github.com/";
      #   };
      # };
    };
    delta.enable = true;
  };

  modules.shell.zsh.enable = true;
  modules.shell.direnv.enable = true;
  modules.ssh.enable = true;
  modules.emacs.enable = true;
}
