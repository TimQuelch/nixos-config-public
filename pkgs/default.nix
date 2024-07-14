{ pkgs, ... }:
with pkgs; {
  fzf-tab-completion = callPackage ./fzf-tab-completion {};
}
