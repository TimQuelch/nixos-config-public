{ config, lib, pkgs, ... }:
{
  # Disabled becuse it was breaking builds
  systemd.services.NetworkManager-wait-online.enable = false;

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05";
}
