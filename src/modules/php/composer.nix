/**
  # Composer

  Composer is a dependency manager for PHP,
  allowing to manage libraries and packages in PHP projects.

  ## 🧐 Features

  ### 🔨 Tasks

  - `reset:php:composer`: Delete Composer `vendor` folder.

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
  recipes-lib,
  ...
}:
let
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.tasks) mkGitIgnoreTask;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.attrsets) optionalAttrs;

  inherit (config.devenv) root;
  inherit (config.languages.php.packages) composer;
  composerCommand = lib.meta.getExe composer;

  phpCfg = config.biapy-recipes.php;
  cfg = phpCfg.composer;

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

        "reset:php:composer" = {
          description = "🔥 Delete 🐘composer 'vendor' folder";
          exec = ''
            echo "Deleting Composer 'vendor' folder"
            [[ -e "''${DEVENV_ROOT}/vendor/" ]] &&
              rm -r "''${DEVENV_ROOT}/vendor/"
          '';
          status = ''test ! -d "''${DEVENV_ROOT}/vendor/"'';
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
      "reset:php:composer" = {
        desc = "🔥 Delete 🐘composer 'vendor' folder";
        preconditions = [
          {
            sh = ''test -d "''${DEVENV_ROOT}/vendor/"'';
            msg = "Project's vendor folder does not exist, skipping.";
          }
        ];
        cmds = [
          ''echo "Deleting composer 'vendor' folder"''
          ''[[ -e "''${DEVENV_ROOT}/vendor/" ]] && rm -r "''${DEVENV_ROOT}/vendor/"''
        ];
        requires.vars = [ "DEVENV_ROOT" ];
      };

      "update:php:composer" = {
        desc = "⬆️ Update 🐘composer packages";
        preconditions = [
          {
            sh = ''test -e "''${DEVENV_ROOT}/composer.json"'';
            msg = "Project's composer.json does not exist, skipping.";
          }
        ];
        cmds = [ ''composer --working-dir="''${DEVENV_ROOT}" update'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      composer-validate = {
        enable = mkDefault true;
        name = "composer validate";
        package = composer;
        extraPackages = [ parallel ];
        files = "composer\.(json|lock)$";
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
        files = "composer\.(json|lock)$";
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
