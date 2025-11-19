/**
  # Composer Dependency Analyser

  `composer-dependency-analyser` detects unused, shadow and misplaced Composer dependencies.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:composer-dependency-analyser`: 🔍 Analyze Composer dependencies.
  - `reset:php:tools:composer-dependency-analyser`: Delete 'composer-dependency-analyser/vendor' folder.

  ### 👷 Commit hooks

  - `composer-dependency-analyser`: 🔍 Analyze Composer dependencies.

  ## 🛠️ Tech Stack

  - [composer-dependency-analyser @ GitHub](https://github.com/shipmonk-rnd/composer-dependency-analyser).

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
  cfg = phpToolsCfg.composer-dependency-analyser;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/composer-dependency-analyser/vendor/bin/composer-dependency-analyser";
  toolConfiguration = {
    name = "Composer Dependency Analyser";
    namespace = "composer-dependency-analyser";
    composerJsonPath = ../../../files/php/tools/composer-dependency-analyser/composer.json;
  };
in
{
  options.biapy-recipes.php.tools.composer-dependency-analyser = mkToolOptions {
    enable = false;
  } "composer-dependency-analyser";

  config = mkIf cfg.enable {
    scripts = {
      composer-dependency-analyser = mkDefault {
        description = "Composer Dependency Analyser - detect unused dependencies";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "Composer Dependency Analyser is not installed."
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
        "ci:lint:php:composer-dependency-analyser" = mkDefault {
          description = "🔍 Analyze Composer dependencies";
          exec = ''
            cd "''${DEVENV_ROOT}"
            composer-dependency-analyser
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:composer-dependency-analyser" = mkDefault (patchGoTask {
          aliases = [ "composer-dependency-analyser" ];
          desc = "🔍 Analyze Composer dependencies";
          cmds = [ "composer-dependency-analyser" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      composer-dependency-analyser = mkDefault {
        enable = true;
        name = "Composer Dependency Analyser";
        inherit (config.languages.php) package;
        entry = "composer-dependency-analyser";
        pass_filenames = false;
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
