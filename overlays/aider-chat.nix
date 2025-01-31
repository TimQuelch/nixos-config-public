final: prev: {
  aider-chat = prev.aider-chat.overridePythonAttrs (oldAttrs: {
    dependencies = oldAttrs.dependencies ++ [
      # Requires boto3 to use bedrock models
      prev.python3Packages.boto3

      # help mode requires this dep available
      (prev.python3Packages.llama-index-embeddings-huggingface.override {
        # the llama-index-core dependency requires 'spacy' which fails to build because of some
        # dep version issue. This simply removes that dependency; it doesn't seem to actually be required.
        llama-index-core =
          prev.python3Packages.llama-index-core.overridePythonAttrs
          (coreAttrs: {
            dependencies = builtins.filter (dep: dep.pname != "spacy")
              coreAttrs.dependencies;
          });
      })
    ];
  });
}
