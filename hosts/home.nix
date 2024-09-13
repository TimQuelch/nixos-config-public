{ config, pkgs, system, user, ... }:
{
  imports = [
    ../modules/shell/zsh.nix
    ../modules/shell/fzf-tab-completion.nix
  ];

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
    ];
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
