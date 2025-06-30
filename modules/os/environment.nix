{
  pkgs,
  rebuild,
  ...
}:
{
  programs.zsh.enable = true;

  # Defer nearly all packages to home manger configs
  environment.systemPackages = with pkgs; [
    rebuild
    vim
    tmux
  ];

  documentation.man = {
    man-db.enable = true;
    generateCaches = false; # disabled because it takes a long time on rebuild
  };

  services.locate.enable = true;
}
