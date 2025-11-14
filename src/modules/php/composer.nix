/**
  # Composer

  Composer is a dependency manager for PHP,
  allowing to manage libraries and packages in PHP projects.

  ## 🧐 Features

  ### 🔨 Tasks

  - `reset:php:composer`: Delete Composer `vendor` folder.
  - `cd:build:php:composer:dump-autoload`: Dump Composer autoload files.

  ### 👷 Commit hooks

  - `composer-validate`: Validate `composer.json` files with `composer validate`.
  - `composer-audit`: Audit `composer.json` files with `composer audit`.

  ## 🛠️ Tech Stack

  - [Composer homepage](https://getcomposer.org/).

  ### 🧑‍💻 Visual Studio Code

  - [Composer @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=DEVSENSE.composer-php-vscode).

  ### 📦 Third party tools

  - [GNU Parallel homepage](https://www.gnu.org/software/parallel/).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [Setting priorities @ NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-option-definitions-setting-priorities).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.tasks) mkGitIgnoreTask;
  inherit (recipes-lib.go-tasks) patchGoTask;

  inherit (config.devenv) root;
  inherit (config.languages.php.packages) composer;
  composerCommand = lib.meta.getExe composer;

  phpCfg = config.biapy-recipes.php;
  cfg = phpCfg.composer;

  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
  parallel = config.biapy-recipes.gnu-parallel.package;
  parallelCommand = lib.meta.getExe parallel;
in
{
  options.biapy-recipes.php.composer = mkToolOptions phpCfg "composer";

  config = mkIf cfg.enable {
    biapy-recipes.gnu-parallel.enable = mkDefault true;

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "DEVSENSE.composer-php-vscode" ];

    languages.php = {
      extensions = [
        "curl"
        "filter"
        "iconv"
        "mbstring"
        "openssl"
      ];
    };

    enterShell = ''
      export PATH="${root}/vendor/bin:$PATH"
    '';

    # https://devenv.sh/tasks/
    tasks =
      optionalAttrs cfg.tasks {
        "biapy-recipes:enterShell:install:php:composer" = {
          description = "Install 🐘composer packages";
          before = [ "devenv:enterShell" ];
          status = ''test -e "''${DEVENV_ROOT}/vendor/autoload.php"'';
          exec = ''
            cd "''${DEVENV_ROOT}"
            if [[ -e "''${DEVENV_ROOT}/composer.json" ]]; then
              ${composerCommand} 'install'
            fi
          '';
        };

        "ci:lint:php:composer-validate" = {
          description = "🔍 Lint 🐘composer.json files";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${fdCommand} '^composer\.json$' --exec ${composerCommand} validate --no-check-publish {}
          '';

        };

        "ci:secops:php:composer-audit" = {
          description = "🕵️‍♂️ Audit 🐘composer.json file";
          exec = ''
            cd "''${DEVENV_ROOT}"
            if [[ -e "''${DEVENV_ROOT}/composer.json" ]]; then
              ${composerCommand} audit
            fi
          '';
        };

        "reset:php:composer" = {
          description = "🔥 Delete 🐘composer 'vendor' folder";
          exec = ''
            echo "Deleting Composer 'vendor' folder"
            if [[ -e "''${DEVENV_ROOT}/vendor/" ]]; then
              rm -r "''${DEVENV_ROOT}/vendor/"
            fi
          '';
          status = ''test ! -d "''${DEVENV_ROOT}/vendor/"'';
        };

        "cd:build:php:composer:dump-autoload" = {
          description = "🔨 Dump 🐘composer autoload files (optimized)";
          exec = ''
            cd "''${DEVENV_ROOT}"
            if [[ -e "''${DEVENV_ROOT}/composer.json" ]]; then
              ${composerCommand} dump-autoload --optimize --strict-psr --classmap-authoritative
            fi
          '';
        };

        "update:php:composer" = {
          description = "⬆️ Update 🐘composer packages";
          exec = ''
            cd "''${DEVENV_ROOT}"
            if [[ -e "''${DEVENV_ROOT}/composer.json" ]]; then
              ${composerCommand} --working-dir="''${DEVENV_ROOT}" 'update'
            fi
          '';
        };
      }
      // mkGitIgnoreTask {
        name = "Composer";
        namespace = "composer";
        ignoredPaths = [ "/vendor/" ];
      };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:php:composer-validate" = patchGoTask {
        desc = "🔍 Lint 🐘composer.json files";
        cmds = [ "fd '^composer\\.json$' --exec composer validate --no-check-publish {}" ];
      };

      "ci:secops:php:composer-audit" = patchGoTask {
        desc = "🕵️‍♂️ Audit 🐘composer.json file";
        cmds = [ "composer audit" ];
      };

      "reset:php:composer" = patchGoTask {
        desc = "🔥 Delete 🐘composer 'vendor' folder";
        preconditions = [
          {
            sh = ''test -d "''${DEVENV_ROOT}/vendor/"'';
            msg = "Project's vendor folder does not exist, skipping.";
          }
        ];
        cmds = [
          ''echo "Deleting composer 'vendor' folder"''
          "[[ -e './vendor/' ]] && rm -r './vendor/'"
        ];
      };

      "cd:build:php:composer:dump-autoload" = patchGoTask {
        aliases = [
          "dump-autoload"
          "composer-dump-autoload"
        ];
        desc = "🔨 Dump 🐘composer autoload files (optimized)";
        preconditions = [
          {
            sh = ''test -e "''${DEVENV_ROOT}/composer.json"'';
            msg = "Project's composer.json does not exist, skipping.";
          }
        ];
        cmds = [ "composer dump-autoload --optimize --strict-psr --classmap-authoritative" ];
      };

      "update:php:composer" = patchGoTask {
        desc = "⬆️ Update 🐘composer packages";
        preconditions = [
          {
            sh = ''test -e "''${DEVENV_ROOT}/composer.json"'';
            msg = "Project's composer.json does not exist, skipping.";
          }
        ];
        cmds = [ ''composer update'' ];
      };
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      composer-validate = {
        enable = mkDefault true;
        name = "composer validate";
        package = composer;
        extraPackages = [ parallel ];
        files = "composer\\.json$";
        entry = "'${parallelCommand}' '${composerCommand}' 'validate' --no-check-publish {} ::: ";
        stages = [
          "pre-commit"
          "pre-push"
        ];
      };

      composer-audit = {
        enable = mkDefault true;
        name = "composer audit";
        after = [ "composer-validate" ];
        package = composer;
        files = "composer\\.json$";
        pass_filenames = false;
        entry = "'${composerCommand}' 'audit'";
        stages = [
          "pre-commit"
          "pre-push"
        ];
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
