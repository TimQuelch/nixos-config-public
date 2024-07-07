{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";

  home = {
    username = "timquelch";
    homeDirectory = "/home/timquelch";
    packages = with pkgs; [
      firefox
      git
      vim
      ripgrep
      fd
      kitty
      htop
      fzf
      #waybar
      #pavucontrol
      (pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];
  };
  fonts.fontconfig.enable = true  ;


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

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "intheloop";
      plugins = [
       "colored-man-pages"
       "fd"
       "fzf"
       "ripgrep"
       "sudo"
      ];
    };
    history = {
      ignoreDups = true;
      ignoreSpace = true;
      ignorePatterns = [ "cd" "z" "exit" "pwd" "ls" ];
      save = 100000;
      size = 100000;
    };
  };

  programs.z-lua = {
    enable = true;
    enableZshIntegration = true;
    options = [ "enhanced" "once" "fzf" ];
  };
}
