{
  lib,
  pkgs,
  config,
  options,
  ...
}:
let
  cfg = config.modules.latex;
in
{
  options.modules.latex = {
    enable = lib.mkEnableOption "git config" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals config.modules.gui.enable [ pkgs.evince ];

    xdg.configFile."latexmk/latexmkrc".text = ''
      $pdf_mode = 1;
      $pdf_previewer = 'start evince';
    '';
  };
}
