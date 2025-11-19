/**
  # PHP Architecture Tester (phpat)

  `phpat` is a PHP Architecture Testing tool that helps you enforce architectural rules in your PHP code.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:phpat`: 🔍 Test PHP architecture with phpat.
  - `reset:php:tools:phpat`: Delete 'phpat/vendor' folder.

  ### 👷 Commit hooks

  - `phpat`: 🔍 Test PHP architecture with phpat.

  ## 🛠️ Tech Stack

  - [phpat @ GitHub](https://github.com/carlosas/phpat).

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
  cfg = phpToolsCfg.phpat;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/phpat/vendor/bin/phpat";
  toolConfiguration = {
    name = "phpat";
    namespace = "phpat";
    composerJsonPath = ../../../files/php/tools/phpat/composer.json;
  };
in
{
  options.biapy-recipes.php.tools.phpat = mkToolOptions { enable = false; } "phpat";

  config = mkIf cfg.enable {
    scripts = {
      phpat = mkDefault {
        description = "phpat - PHP Architecture Tester";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "phpat is not installed."
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
        "ci:lint:php:phpat" = mkDefault {
          description = "🔍 Test PHP architecture with phpat";
          exec = ''
            cd "''${DEVENV_ROOT}"
            phpat
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:phpat" = mkDefault (patchGoTask {
          aliases = [ "phpat" ];
          desc = "🔍 Test PHP architecture with phpat";
          cmds = [ "phpat" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      phpat = mkDefault {
        enable = true;
        name = "phpat";
        inherit (config.languages.php) package;
        entry = "phpat";
        pass_filenames = false;
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
