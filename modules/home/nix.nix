{
  pkgs,
  lib,
  ...
}:
{
  # Configure nix in user config as well as root so that we have user-level garbage collection. This
  # ensures old home manager profiles are cleaned up
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      cores = 0;
    };
    gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
