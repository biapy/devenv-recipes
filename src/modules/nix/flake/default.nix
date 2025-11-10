/**
  # Nix Flakes

  Support for Nix flakes management and validation.

  ## 🧐 Features

  ### 🔨 Tasks

  - `update:nix:flake-update`: Update flake lock files with `devenv update`.

  ### Submodules

  - Flake checker for health checks
  - Flake lock file updates

  ## 🛠️ Tech Stack

  - [Nix Flakes @ NixOS Wiki](https://nixos.wiki/wiki/Flakes).
  - [devenv update @ Devenv Reference Manual](https://devenv.sh/reference/cli/#devenv-update).
*/
args@{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.lists) map;
  inherit (lib) mkIf mkDefault;
  inherit (lib.attrsets) optionalAttrs;
  inherit (recipes-lib.go-tasks) patchGoTask;

  cfg = config.biapy-recipes.nix.flake;
in
{
  imports = map (path: import path args) [ ./flake-checker.nix ];

  options.biapy-recipes.nix.flake = recipes-lib.modules.mkModuleOptions "Nix Flakes";

  config = mkIf cfg.enable {
    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "update:nix:flake-update" = mkDefault {
        description = "⬆️ Update ❄️Nix flake lock files";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          nix flake update
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "update:nix:flake-update" = patchGoTask {
        aliases = [ "flake-update" ];
        desc = "⬆️ Update ❄️Nix flake lock files";
        cmds = [ "nix flake update" ];
      };
    };
  };
}
