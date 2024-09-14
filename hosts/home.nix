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
      kitty
      htop
      fzf
      bitwarden
      (pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      iosevka
      yubikey-manager
      duf
      dust
      ncdu
      sops
      magic-wormhole
      age
      sqlite
    ];
    sessionVariables = {
      EDITOR = "vim";
    };
  };
  fonts.fontconfig.enable = true;

  wayland.windowManager.hyprland.enable = false;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind = [ 
      "$mod, F, exec, firefox"
    ]
    ++ (
      builtins.concatLists (builtins.genList (
        x: let 
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in [
          "$mod, ${ws}, workspace, ${toString (x + 1)}"
          "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
        ]
      )
      10)
    );
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };

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
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com";
        };
      };
    };
    delta.enable = true;
  };

  modules.shell.zsh.enable = true;
  modules.shell.fzf-tab-completion.enable = true;
  modules.ssh.enable = true;
}
