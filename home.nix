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

}
