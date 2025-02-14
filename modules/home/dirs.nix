{
  lib,
  config,
  options,
  pkgs,
  ...
}:
let
  cfg = config.modules.dirs;
  homeDir = config.home.homeDirectory;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.modules.dirs = {
    enable = mkEnableOption "xdg dirs";
  };

  config = mkIf cfg.enable {

    # Some GUI programs consult this, ignoring XDG conventions if it isn't
    # See https://github.com/hlissner/dotfiles/blob/55194e703d1fe82e7e0ffd06e460f1897b6fc404/modules/xdg.nix#L44-L46
    home.packages = [ pkgs.xdg-user-dirs ];

    xdg = {
      enable = true;

      cacheHome = "${homeDir}/.cache";
      configHome = "${homeDir}/.config";
      dataHome = "${homeDir}/.local/share";
      stateHome = "${homeDir}/.local/state";

      userDirs = {
        enable = true;
        desktop = "${homeDir}/desktop";
        documents = "${homeDir}/documents";
        download = "${homeDir}/download";
        music = "${homeDir}/pictures";
        pictures = "${homeDir}/pictures";
        publicShare = "${homeDir}/public";
        templates = "${homeDir}/documents";
        videos = "${homeDir}/pictures";
      };
    };

    home.sessionVariables = {
      GOPATH = "${config.xdg.dataHome}/go";
      __GL_SHADER_DISK_CACHE_PATH = "${config.xdg.cacheHome}/nv";
    };
  };
}
