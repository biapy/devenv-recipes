/**
  # PHP Semantic Versioning Checker

  `php-semver-checker` is a tool that compares two source sets and determines the appropriate semantic versioning to apply.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:php-semver-checker`: 🔍 Check 🐘PHP semantic versioning compatibility.
  - `reset:php:tools:php-semver-checker`: Delete 'php-semver-checker/vendor' folder.

  ## 🛠️ Tech Stack

  - [php-semver-checker @ GitHub](https://github.com/tomzx/php-semver-checker).

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
  cfg = phpToolsCfg.php-semver-checker;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/php-semver-checker/vendor/bin/php-semver-checker";
  toolConfiguration = {
    name = "php-semver-checker";
    namespace = "php-semver-checker";
    composerJsonPath = ../../../files/php/tools/php-semver-checker/composer.json;
  };
in
{
  options.biapy-recipes.php.tools.php-semver-checker = mkToolOptions {
    enable = false;
  } "php-semver-checker";

  config = mkIf cfg.enable {
    scripts = {
      php-semver-checker = mkDefault {
        description = "php-semver-checker - semantic versioning checker";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "php-semver-checker is not installed."
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
        "ci:lint:php:php-semver-checker" = mkDefault {
          description = "🔍 Check 🐘PHP semantic versioning compatibility";
          exec = ''
            cd "''${DEVENV_ROOT}"
            php-semver-checker compare --target HEAD
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:php-semver-checker" = mkDefault (patchGoTask {
          aliases = [ "php-semver-checker" ];
          desc = "🔍 Check 🐘PHP semantic versioning compatibility";
          cmds = [ "php-semver-checker compare --target HEAD" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # See full reference at https://devenv.sh/reference/options/
  };
}
