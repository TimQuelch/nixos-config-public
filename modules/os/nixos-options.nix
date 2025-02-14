{
  lib,
  config,
  pkgs,
  options,
  ...
}:
let
  cfg = config.modules.os.nixos-options;
  opts = pkgs.writeTextFile {
    name = "nixos-options.json";
    text =
      let
        optionList' = lib.optionAttrSetToDocList options;
        optionList = builtins.filter (v: v.visible && !v.internal) optionList';
      in
      builtins.toJSON optionList;
  };
  showopt = pkgs.writeShellApplication {
    name = "showopt";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      jq ".[] | select(.name == \"$1\")" < ${opts}
    '';
  };
  nixopts = pkgs.writeShellApplication {
    name = "nixopts";
    runtimeInputs = with pkgs; [
      jq
      fzf
      showopt
    ];
    text = ''
      result=$(jq -r '.[].name' ${opts} | fzf --preview="showopt {}")
      showopt "$result"
    '';
  };
in
{
  options.modules.os.nixos-options.enable = lib.mkEnableOption "enable nixos options search";

  config = lib.mkIf cfg.enable { environment.systemPackages = [ nixopts ]; };
}
