final: prev: {
  custom = {
    hyprland-scripting = final.callPackage ../packages/hyprland-scripting { };
    bash-my-aws = final.callPackage ../packages/bash-my-aws { };
  };
}
