final: prev: {
  mujmap = prev.mujmap.overrideAttrs (
    finalAttrs: prevAttrs: {
      version =
        final.lib.warnIf (prevAttrs.version != "0.2.0")
          "upstream mujmap has been updated to ${prevAttrs.version}. Overlay may not be necessary anymore"
          "latest";

      src = prevAttrs.src.override {
        rev = "5f700af890769185ad99d4aae9f53496bb2aa6f2";
        sha256 = "sha256-mSJ6uyZSaWWdhqiYNcIm7lC6PZZrZ8PSdxfu+s9MZD0=";
      };

      cargoDeps = final.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) src;
        hash = "sha256-snCDGg7Nx3ckSPNFxvu8nhVr8SO3sjWIFA0WCRqH224=";
      };

      patches = prevAttrs.patches ++ [ ./0001-Override-chunk_size-for-upload.patch ];
    }
  );
}
