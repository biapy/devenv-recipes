/**
  # Nix Flake Update

  Update Nix flake lock files using devenv update.

  ## 🧐 Features

  ### 🔨 Tasks

  - `update:nix:flake-update`: Update flake lock files with `devenv update`.

  ## 🛠️ Tech Stack

  - [devenv update @ Devenv Reference Manual](https://devenv.sh/reference/cli/#devenv-update).

  ## 🙇 Acknowledgements

  - [Nix Flakes @ NixOS Wiki](https://nixos.wiki/wiki/Flakes).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.attrsets) optionalAttrs;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  flakeCfg = config.biapy-recipes.nix.flake;
  cfg = flakeCfg.flake-update;
in
{
  options.biapy-recipes.nix.flake.flake-update = mkToolOptions flakeCfg "Nix flake update";

  config = mkIf cfg.enable {
    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "update:nix:flake-update" = mkDefault {
        description = "⬆️ Update ❄️Nix flake lock files";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          devenv update
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "update:nix:flake-update" = patchGoTask {
        aliases = [ "flake-update" ];
        desc = "⬆️ Update ❄️Nix flake lock files";
        cmds = [ "devenv update" ];
      };
    };
  };
}
