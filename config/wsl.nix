{
  inputs,
  pkgs,
  config,
  user,
  ...
}:
{
  imports = [ inputs.wsl.nixosModules.wsl ];
  wsl.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
}
