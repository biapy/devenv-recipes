/**
  # PHPLint

  `phplint` is a tool that can speed up linting of php files by running several
  lint processes at once.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:phplint`: 🔍 Lint 🐘PHP files with `phplint`.
  - `reset:php:tools:phplint`: Delete 'phplint/vendor' folder.

  ### 👷 Commit hooks

  - `phplint`: 🔍 Lint 🐘PHP files with `phplint`.

  ## 🛠️ Tech Stack

  - [PHPLint @ GitHub](https://github.com/overtrue/phplint).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.phplint @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphplint).
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
  cfg = phpToolsCfg.phplint;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/phplint/vendor/overtrue/phplint/bin/phplint";
  toolConfiguration = {
    name = "PHPLint";
    namespace = "phplint";
    composerJsonPath = ../../../files/php/tools/phplint/composer.json;
    configFiles = {
      ".phplint.yml" = ../../../files/php/.phplint.yml;
    };
  };
in
{
  options.biapy-recipes.php.tools.phplint = mkToolOptions phpToolsCfg "phplint";

  config = mkIf cfg.enable {
    scripts = {
      phplint = {
        description = "PHPLint";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "PHPLint is not installed."
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
        "ci:lint:php:phplint" = {
          description = "🔍 Lint 🐘PHP files with PHPLint";
          exec = ''
            cd "''${DEVENV_ROOT}"
            phplint
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:phplint" = patchGoTask {
          aliases = [ "phplint" ];
          desc = "🔍 Lint 🐘PHP files with PHPLint";
          cmds = [ ''phplint --colors'' ];
        };
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      phplint = {
        enable = mkDefault true;
        name = "PHPLint";
        inherit (config.languages.php) package;
        files = "\\.php$";
        entry = "phplint";
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
