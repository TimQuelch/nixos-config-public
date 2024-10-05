{ buildGoModule }:
buildGoModule {
  name = "hyprland-scripting";
  src = ./.;
  vendorHash = null;
  postInstall = ''
    mv $out/bin/main $out/bin/hyprland-listener
  '';
}
