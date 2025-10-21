/**
  # age

  `age` is a simple, modern and secure file encryption tool, format,
  and Go library.

  ## 🛠️ Tech Stack

  - [age @ GitHub](https://github.com/FiloSottile/age).

  ### 🦀 Rust alternatives

  - [rage @ GitHub](https://github.com/str4d/rage).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;

  secretsCfg = config.biapy-recipes.secrets;
  cfg = secretsCfg.age;

  inherit (pkgs) age;
in
{
  options.biapy-recipes.secrets.age.enable = mkOption {
    type = types.bool;
    description = "Enable age integration";
    default = secretsCfg.enable;
  };

  config = mkIf cfg.enable { packages = [ age ]; };
}
