/**
  # PHP Magic Number Detector (phpmnd)

  `phpmnd` is a tool that helps you detect magic numbers in your PHP code.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:phpmnd`: 🔍 Detect magic numbers in 🐘PHP code.
  - `reset:php:tools:phpmnd`: Delete 'phpmnd/vendor' folder.

  ### 👷 Commit hooks

  - `phpmnd`: 🔍 Detect magic numbers in 🐘PHP code.

  ## 🛠️ Tech Stack

  - [phpmnd @ GitHub](https://github.com/povils/phpmnd).

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
  cfg = phpToolsCfg.phpmnd;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/phpmnd/vendor/bin/phpmnd";
  toolConfiguration = {
    name = "phpmnd";
    namespace = "phpmnd";
    composerJsonPath = ../../../files/php/tools/phpmnd/composer.json;
  };
in
{
  options.biapy-recipes.php.tools.phpmnd = mkToolOptions { enable = false; } "phpmnd";

  config = mkIf cfg.enable {
    scripts = {
      phpmnd = mkDefault {
        description = "phpmnd - PHP Magic Number Detector";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "phpmnd is not installed."
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
        "ci:lint:php:phpmnd" = mkDefault {
          description = "🔍 Detect magic numbers in 🐘PHP code";
          exec = ''
            cd "''${DEVENV_ROOT}"
            phpmnd src
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:phpmnd" = mkDefault (patchGoTask {
          aliases = [ "phpmnd" ];
          desc = "🔍 Detect magic numbers in 🐘PHP code";
          cmds = [ "phpmnd src" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      phpmnd = mkDefault {
        enable = true;
        name = "phpmnd";
        inherit (config.languages.php) package;
        entry = "phpmnd";
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
