/**
  # Bitwarden Secrets Manager

  The Secrets Manager command-line interface (CLI) is a powerful tool for
  retrieving and injecting your secrets.
  The Secrets Manager CLI can be used to organize your vault with create,
  delete, edit, and list your secrets and projects.

  Set the API key in `BWS_ACCESS_TOKEN` (in the project `.env.local` with dotenv).

  ❗ Requires `allowUnfree: true` in `devenv.yaml`.

  ⚠️ Vaultwarden doesn't support `bws`. It's a commercial Bitwarden feature.

  ## 🛠️ Tech Stack

  - [Secrets Manager CLI @ BitWarden](https://bitwarden.com/help/secrets-manager-cli/)
    ([Bitwarden Secrets Manager SDK @ GitHub](https://github.com/bitwarden/sdk-sm)).
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
  cfg = secretsCfg.bitwarden;

  inherit (pkgs) bws;
in
{
  options.biapy-recipes.secrets.bitwarden.enable = mkOption {
    type = types.bool;
    description = "Enable bitwarden Secrets Manager CLI integration";
    default = false;
  };

  config = mkIf cfg.enable { packages = [ bws ]; };
}
