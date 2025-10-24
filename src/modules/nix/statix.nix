/**
  # Statix

  statix provides linting and suggestions for the Nix programming language.

  - `statix check` highlights antipatterns in Nix code.
  - `statix fix` can fix several such occurrences.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:nix:statix`: Lint `.nix` files with `statix check`.
  - `ci:fix:nix:statix`: Fix `.nix` files with `statix fix`.

  ### 👷 Commit hooks

  - `statix`: Lint `.nix` files with `statix check`.

  ## 🛠️ Tech Stack

  - [statix @ git.peppe.rs](https://git.peppe.rs/languages/statix/about/).
  - [statix @ GitHub](https://github.com/oppiliappan/statix).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.statix @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksstatix).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  nixCfg = config.biapy-recipes.nix;
  cfg = nixCfg.statix;

  statix = cfg.package;
  statixCommand = lib.meta.getExe statix;
in
{
  options.biapy-recipes.nix.statix = mkToolOptions nixCfg "statix" // {
    package = mkOption {
      description = "The statix package to use.";
      defaultText = "pkgs.statix";
      type = types.package;
      default = config.git-hooks.hooks.statix.package;
    };
  };

  config = mkIf cfg.enable {
    packages = [ statix ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks { statix.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:nix:statix" = mkDefault {
        description = "🔍 Lint ❄️Nix files with statix";
        exec = ''
          set -o 'errexit'

          cd "''${DEVENV_ROOT}"
          ${statixCommand} check
        '';
      };

      "ci:fix:nix:statix" = mkDefault {
        description = "🧹 Fix ❄️Nix files with statix";
        exec = ''
          set -o 'errexit'

          cd "''${DEVENV_ROOT}"
          ${statixCommand} fix
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:nix:statix" = patchGoTask {
        aliases = [ "statix" ];
        desc = "🔍 Lint ❄️Nix files with statix";
        cmds = [ "statix check" ];
      };

      "ci:fix:nix:statix" = patchGoTask {
        desc = "🧹 Fix ❄️Nix files with statix";
        cmds = [ "statix fix" ];
      };
    };
  };
}
