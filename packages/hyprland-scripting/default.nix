{ buildGoModule }:
buildGoModule {
  name = "hyprland-scripting";
  src = ./.;
  vendorHash = null;
}
