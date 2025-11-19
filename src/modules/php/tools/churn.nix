/**
  # churn-php

  `churn-php` discovers files that have the highest number of commits in your repository.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:churn`: 📊 Analyze code churn with churn-php.

  ## 🛠️ Tech Stack

  - [churn-php @ GitHub](https://github.com/bmitch/churn-php).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  config,
  lib,
  php-recipe-lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (php-recipe-lib) mkPhpToolTasks mkPhpToolGoTasks;

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.churn;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/churn/vendor/bin/churn";
  toolConfiguration = {
    name = "churn-php";
    namespace = "churn";
    composerJsonPath = ../../../files/php/tools/churn/composer.json;
  };
in
{
  options.biapy-recipes.php.tools.churn = mkToolOptions { enable = false; } "churn";

  config = mkIf cfg.enable {
    scripts = {
      churn = mkDefault {
        description = "churn-php - discover files with most commits";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "churn-php is not installed."
            exit 1
          fi

          ${phpCommand} '${toolCommand}' "''${@}"
        '';
      };
    };

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:lint:php:churn" = mkDefault {
          description = "📊 Analyze code churn with churn-php";
          exec = ''
            cd "''${DEVENV_ROOT}"
            churn run
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:churn" = mkDefault (patchGoTask {
          aliases = [ "churn" ];
          desc = "📊 Analyze code churn with churn-php";
          cmds = [ "churn run" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # See full reference at https://devenv.sh/reference/options/
  };
}
