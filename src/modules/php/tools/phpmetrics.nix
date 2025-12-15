/**
  # PhpMetrics

  `phpmetrics` provides software metrics about PHP projects and generates HTML reports with analysis.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:phpmetrics`: 📊 Generate 🐘PHP metrics report with PhpMetrics.
  - `reset:php:tools:phpmetrics`: Delete 'phpmetrics/vendor' folder.

  ## 🛠️ Tech Stack

  - [PhpMetrics homepage](https://phpmetrics.github.io/website/).
  - [PhpMetrics @ GitHub](https://github.com/phpmetrics/PhpMetrics).

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
  cfg = phpToolsCfg.phpmetrics;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/phpmetrics/vendor/bin/phpmetrics";
  toolConfiguration = {
    name = "PhpMetrics";
    namespace = "phpmetrics";
    composerJsonPath = ../../../files/php/tools/phpmetrics/composer.json;
    configFiles = {
      ".phpmetrics.yml" = ../../../files/php/.phpmetrics.yml;
    };
  };
in
{
  options.biapy-recipes.php.tools.phpmetrics = mkToolOptions { enable = false; } "phpmetrics";

  config = mkIf cfg.enable {

    languages.php.extensions = [ "yaml" ];

    scripts = {
      phpmetrics = mkDefault {
        description = "PhpMetrics - PHP static analysis tool";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "PhpMetrics is not installed."
            exit 1
          fi

          ${phpCommand} -d 'error_reporting=~E_DEPRECATED' '${toolCommand}' "''${@}"
        '';
      };
    };

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:reports:php:phpmetrics" = mkDefault {
          description = "📊 Generate 🐘PHP metrics report with PhpMetrics";
          exec = ''
            cd "''${DEVENV_ROOT}"
            phpmetrics --config='.phpmetrics.yml'
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:reports:php:phpmetrics" = mkDefault (patchGoTask {
          aliases = [ "phpmetrics" ];
          desc = "📊 Generate 🐘PHP metrics report with PhpMetrics";
          cmds = [ "phpmetrics --config='.phpmetrics.yml'" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # See full reference at https://devenv.sh/reference/options/
  };
}
