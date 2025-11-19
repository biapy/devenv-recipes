/**
  # PHPArkitect

  `phparkitect` helps you to keep your PHP codebase coherent and solid by permitting to add some architectural constraint check to your workflow.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:phparkitect`: 🔍 Check 🐘PHP architecture with PHPArkitect.
  - `reset:php:tools:phparkitect`: Delete 'phparkitect/vendor' folder.
  - `cache:clear:php:phparkitect`: Clear PHPArkitect cache.

  ### 👷 Commit hooks

  - `phparkitect`: 🔍 Check 🐘PHP architecture with PHPArkitect.

  ## 🛠️ Tech Stack

  - [PHPArkitect @ GitHub](https://github.com/phparkitect/arkitect).

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
  cfg = phpToolsCfg.phparkitect;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/phparkitect/vendor/bin/phparkitect";
  toolConfiguration = {
    name = "PHPArkitect";
    namespace = "phparkitect";
    composerJsonPath = ../../../files/php/tools/phparkitect/composer.json;
  };
in
{
  options.biapy-recipes.php.tools.phparkitect = mkToolOptions { enable = false; } "phparkitect";

  config = mkIf cfg.enable {
    scripts = {
      phparkitect = mkDefault {
        description = "PHPArkitect - PHP architectural constraints checker";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "PHPArkitect is not installed."
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
        "ci:lint:php:phparkitect" = mkDefault {
          description = "🔍 Check 🐘PHP architecture with PHPArkitect";
          exec = ''
            cd "''${DEVENV_ROOT}"
            phparkitect check
          '';
        };

        "cache:clear:php:phparkitect" = mkDefault {
          description = "🗑️ Clear PHPArkitect cache";
          exec = ''
            cd "''${DEVENV_ROOT}"
            rm -rf .phparkitect
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:phparkitect" = mkDefault (patchGoTask {
          aliases = [ "phparkitect" ];
          desc = "🔍 Check 🐘PHP architecture with PHPArkitect";
          cmds = [ "phparkitect check" ];
        });

        "cache:clear:php:phparkitect" = mkDefault (patchGoTask {
          aliases = [
            "phparkitect-cc"
            "phparkitect:cc"
          ];
          desc = "🗑️ Clear PHPArkitect cache";
          cmds = [ "rm -rf .phparkitect" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      phparkitect = mkDefault {
        enable = true;
        name = "PHPArkitect";
        inherit (config.languages.php) package;
        entry = "phparkitect";
        args = [ "check" ];
        pass_filenames = false;
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
