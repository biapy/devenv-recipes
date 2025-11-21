{
  config,
  lib,
  recipes-lib,
  pkgs,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  cfg = config.biapy-recipes.go.air;

  inherit (pkgs) air;
  airCommand = lib.meta.getExe air;
in
{

  options.biapy-recipes.go.air = mkToolOptions { enable = false; } "Air";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ air ];

    # https://devenv.sh/processes/
    processes.air-server.exec = "${airCommand}";

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "dev:serve:air:server" = mkDefault {
        description = "🚀 Start 🐹Go development server with Air live reload";
        exec = "devenv processes up air-server";
      };

      "ci:lint:air:check" = mkDefault {
        description = "🔍 Check Air configuration";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${airCommand} -v
        '';
      };

      "biapy-recipes:air:init" = mkDefault {
        description = "🎬 Initialize Air configuration file";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          if [[ ! -e ".air.toml" ]]; then
            ${airCommand} init
          fi
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "dev:serve:air:server" = patchGoTask {
        aliases = [ "air-server" ];
        desc = "🚀 Start 🐹Go development server with Air live reload";
        cmds = [ "devenv processes up air-server" ];
      };

      "ci:lint:air:check" = patchGoTask {
        aliases = [ "air-check" ];
        desc = "🔍 Check Air configuration";
        cmds = [ "air -v" ];
      };

      "biapy-recipes:air:init" = patchGoTask {
        aliases = [ "air-init" ];
        desc = "🎬 Initialize Air configuration file";
        cmds = [ "air init" ];
      };
    };
  };
}
