final: prev: {
  custom = {
    hyprland-scripting = final.callPackage ../packages/hyprland-scripting { };
    nix-shell-helper = final.callPackage ../packages/nix-shell-helper { };
  };
}
