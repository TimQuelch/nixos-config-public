{
  lib,
  ...
}:
{
  modules.git.enable = lib.mkDefault true;
  modules.shell.zsh.enable = lib.mkDefault true;
  modules.shell.direnv.enable = lib.mkDefault true;
  modules.ssh.enable = lib.mkDefault true;
  modules.emacs.enable = lib.mkDefault true;
  modules.dirs.enable = lib.mkDefault true;
  modules.aider.enable = lib.mkDefault true;
  modules.nix-shell-helper.enable = lib.mkDefault true;
  modules.cloud.aws.enable = lib.mkDefault true;
  modules.cloud.azure.enable = lib.mkDefault true;

  home.stateVersion = lib.mkDefault "25.05";
}
