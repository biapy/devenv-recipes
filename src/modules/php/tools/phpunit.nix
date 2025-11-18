/**
  # PHPUnit

  `phpunit` is a programmer-oriented testing framework for PHP.

  This module provides tasks and scripts to run PHPUnit tests from your project.
  It expects PHPUnit to be installed in your project (via Composer).

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:tests:php:phpunit`: 🧪 Run 🐘PHP tests with PHPUnit.
  - `ci:coverage:php:phpunit`: 📊 Generate 🐘PHP test coverage report with PHPUnit.

  ### 👷 Commit hooks

  - `phpunit`: 🧪 Run 🐘PHP tests with PHPUnit.

  ## 🛠️ Tech Stack

  - [PHPUnit homepage](https://phpunit.de/).
  - [PHPUnit @ GitHub](https://github.com/sebastianbergmann/phpunit).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.phpunit @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphpunit).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.modules) mkToolOptions;

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.phpunit;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
in
{
  options.biapy-recipes.php.tools.phpunit = mkToolOptions phpToolsCfg "phpunit";

  config = mkIf cfg.enable {
    scripts = {
      phpunit = {
        description = "PHPUnit - PHP testing framework";
        exec = ''
          PHPUNIT_BIN=""

          # Check common PHPUnit locations
          if [[ -e "${root}/vendor/bin/phpunit" ]]; then
            PHPUNIT_BIN="${root}/vendor/bin/phpunit"
          elif [[ -e "${root}/bin/phpunit" ]]; then
            PHPUNIT_BIN="${root}/bin/phpunit"
          else
            echo "PHPUnit not found. Please install it via Composer."
            exit 1
          fi

          ${phpCommand} "$PHPUNIT_BIN" "''${@}"
        '';
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:tests:php:phpunit" = {
        description = "🧪 Run 🐘PHP tests with PHPUnit";
        exec = ''
          cd "''${DEVENV_ROOT}"
          phpunit --no-coverage
        '';
      };

      "ci:coverage:php:phpunit" = {
        description = "📊 Generate 🐘PHP test coverage report with PHPUnit";
        exec = ''
          cd "''${DEVENV_ROOT}"
          XDEBUG_MODE=coverage phpunit
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:tests:php:phpunit" = patchGoTask {
        aliases = [ "phpunit" ];
        desc = "🧪 Run 🐘PHP tests with PHPUnit";
        cmds = [ "phpunit --no-coverage" ];
      };

      "ci:coverage:php:phpunit" = patchGoTask {
        aliases = [ "phpunit-coverage" ];
        desc = "📊 Generate 🐘PHP test coverage report with PHPUnit";
        cmds = [ "phpunit" ];
        env = {
          # Disable code coverage collection in git hooks to speed up tests
          XDEBUG_MODE = "coverage";
        };
      };
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      phpunit = {
        enable = mkDefault true;
        name = "PHPUnit";
        inherit (config.languages.php) package;
        entry = "phpunit";
        args = [ "--no-coverage" ];
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
