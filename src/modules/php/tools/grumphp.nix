/**
  # GrumPHP

  `grumphp` is a PHP code-quality tool that runs tasks on git commit and push events.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:grumphp`: 🔍 Run GrumPHP quality checks.
  - `reset:php:tools:grumphp`: Delete 'grumphp/vendor' folder.

  ### 👷 Commit hooks

  - `grumphp`: 🔍 Run GrumPHP quality checks on commit.

  ## 🛠️ Tech Stack

  - [GrumPHP homepage](https://github.com/phpro/grumphp).

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
  cfg = phpToolsCfg.grumphp;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/grumphp/vendor/bin/grumphp";
  toolConfiguration = {
    name = "GrumPHP";
    namespace = "grumphp";
    composerJsonPath = ../../../files/php/tools/grumphp/composer.json;
    configFiles = {
      "grumphp.yml" = ../../../files/php/grumphp.yml;
    };
  };
in
{
  options.biapy-recipes.php.tools.grumphp = mkToolOptions { enable = false; } "grumphp";

  config = mkIf cfg.enable {
    scripts = {
      grumphp = {
        description = "GrumPHP - PHP code-quality tool";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "GrumPHP is not installed."
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
        "ci:lint:php:grumphp" = {
          description = "🔍 Run GrumPHP quality checks";
          exec = ''
            cd "''${DEVENV_ROOT}"
            grumphp run
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:grumphp" = patchGoTask {
          aliases = [ "grumphp" ];
          desc = "🔍 Run GrumPHP quality checks";
          cmds = [ "grumphp run" ];
        };
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      grumphp = {
        enable = mkDefault false;
        name = "GrumPHP";
        entry = "grumphp run";
        pass_filenames = false;
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
