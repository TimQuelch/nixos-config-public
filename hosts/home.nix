{ config, pkgs, system, user, ... }:
{
  imports = [
    ../modules/shell/zsh.nix
    ../modules/shell/fzf-tab-completion.nix
  ];

  # Setup secrets
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/sops-nix.txt";
    age.generateKey = true;
  };

  sops.secrets = {
    "ssh_auth_keys/primary_github" = {};
    "ssh_auth_keys/primary_github.pub" = {};
    "ssh_auth_keys/client_github" = {};
    "ssh_auth_keys/client_github.pub" = {};
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
      age
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
  };

  modules.shell.zsh.enable = true;
  modules.shell.fzf-tab-completion.enable = true;
}
