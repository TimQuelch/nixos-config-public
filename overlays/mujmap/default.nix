final: prev: {
  mujmap = prev.mujmap.overrideAttrs (prevAttrs: rec {
    version =
      prev.lib.warnIf (prevAttrs.version != "0.2.0")
        "upstream mujmap has been updated to ${prevAttrs.version}. Overlay may not be necessary anymore"
        "latest";

    src = prev.fetchFromGitHub {
      owner = "elizagamedev";
      repo = "mujmap";
      rev = "5f700af890769185ad99d4aae9f53496bb2aa6f2";
      hash = "sha256-mSJ6uyZSaWWdhqiYNcIm7lC6PZZrZ8PSdxfu+s9MZD0=";
    };

    patches = [ ./0001-Override-chunk_size-for-upload.patch ];

    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-snCDGg7Nx3ckSPNFxvu8nhVr8SO3sjWIFA0WCRqH224=";
    };
  });
}
