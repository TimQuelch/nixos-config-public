# always trust the public key of the cache. This can be useful on systems which can't directly
# access the cache but need to trust packages that were originally sourced from the cache
{
  nix.settings.trusted-public-keys = [ "theta:vy3RV3IOlEGdaQjv5Z/6fZT0HLrLzLdnyMzBNOEgXDM==" ];
}
