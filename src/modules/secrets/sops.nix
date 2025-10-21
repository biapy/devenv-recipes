/**
  # SOPS

  ## 🧐 Features

  ### 🔨 Tasks

  ### 👷 Commit hooks

  - `pre-commit-hook-ensure-sops`: Ensure SOPS encryption for secrets.

  ## 🛠️ Tech Stack

  - [SOPS homepage](https://getsops.io/)
    ([SOPS: Secrets OPerationS @ GitHub](https://github.com/getsops/sops)).
  - [pre-commit-hook-ensure-sops @ GitHub](https://github.com/yuvipanda/pre-commit-hook-ensure-sops).

  ### 🦀 Rust alternatives

  - [ROPS homepage](https://gibbz00.github.io/rops/)
    ([ROPS @ GitHub](https://github.com/gibbz00/rops)).

  ### 🧑‍💻 Visual Studio Code

  - [@signageos/vscode-sops @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=signageos.signageos-vscode-sops).

  ## 🙇 Acknowledgements

  - [Protégez vos secrets DevOps avec SOPS @ DevSecOps :fr:](https://blog.stephane-robert.info/docs/securiser/secrets/sops/).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  inherit (recipes-lib.modules) mkGitHooksOption;

  secretsCfg = config.biapy-recipes.secrets;
  cfg = secretsCfg.sops;

  inherit (pkgs) age sops;
in
{

  options.biapy-recipes.secrets.sops = {
    enable = mkOption {
      type = types.bool;
      description = "Enable SOPS integration";
      default = false;
    };
  }
  // (mkGitHooksOption "SOPS");

  config = mkIf cfg.enable {
    packages = [
      age
      sops
    ];

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "signageos.signageos-vscode-sops" ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks.pre-commit-hook-ensure-sops.enable = true;
  };
}
