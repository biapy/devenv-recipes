/**
  # Passbolt CLI

  A CLI tool to interact with Passbolt,
  a Open source Password Manager for Teams.

  ## 🛠️ Tech Stack

  - [go-passbolt-cli @ GitHub](https://github.com/passbolt/go-passbolt-cli).
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
  cfg = secretsCfg.passbolt;

  inherit (pkgs) go-passbolt-cli;
in
{
  options.biapy-recipes.secrets.passbolt.enable = mkOption {
    type = types.bool;
    description = "Enable passbolt CLI integration";
    default = false;
  };

  config = mkIf cfg.enable { packages = [ go-passbolt-cli ]; };
}
