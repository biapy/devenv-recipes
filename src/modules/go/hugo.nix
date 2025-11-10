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

  cfg = config.biapy-recipes.go.hugo;

  inherit (pkgs) hugo;
  hugoCommand = lib.meta.getExe hugo;
in
{

  options.biapy-recipes.go.hugo = mkToolOptions { enable = false; } "Hugo";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ hugo ];

    # https://devenv.sh/processes/
    processes.hugo-server.exec = "${hugoCommand} server --buildDrafts";

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "cd:build:hugo:build" = mkDefault {
        description = "🔨 Build 🌐Hugo site";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${hugoCommand} --gc --minify
        '';
      };

      "dev:serve:hugo:server" = mkDefault {
        description = "🚀 Start 🌐Hugo development server";
        exec = "devenv processes up hugo-server";
      };

      "ci:lint:hugo:check" = mkDefault {
        description = "🔍 Check 🌐Hugo site for errors";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${hugoCommand} --gc --minify --logLevel info
        '';
      };

      "update:hugo:mod-tidy" = mkDefault {
        description = "⬆️ Update 🌐Hugo modules with \`hugo mod tidy\`";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${hugoCommand} mod tidy
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "cd:build:hugo:build" = patchGoTask {
        aliases = [ "hugo-build" ];
        desc = "🔨 Build 🌐Hugo site";
        cmds = [ "hugo --gc --minify" ];
      };

      "dev:serve:hugo:server" = patchGoTask {
        aliases = [ "hugo-server" ];
        desc = "🚀 Start 🌐Hugo development server";
        cmds = [ "devenv processes up hugo-server" ];
      };

      "ci:lint:hugo:check" = patchGoTask {
        aliases = [ "hugo-check" ];
        desc = "🔍 Check 🌐Hugo site for errors";
        cmds = [ "hugo --gc --minify --logLevel info" ];
      };

      "update:hugo:mod-tidy" = patchGoTask {
        aliases = [ "hugo-mod-tidy" ];
        desc = "⬆️ Update 🌐Hugo modules with \`hugo mod tidy\`";
        cmds = [ "hugo mod tidy" ];
      };
    };
  };
}
