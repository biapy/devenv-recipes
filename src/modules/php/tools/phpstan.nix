/**
  # PHPStan

  `phpstan` on finding errors in your code without actually running it.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:phpstan`: Lint PHP files with PHPStan.
  - `reset:php:tools:phpstan`: Delete 'rector/phpstan' folder.

  ### 👷 Commit hooks

  - `phpstan`: Lint PHP files with PHPStan.

  ## 🛠️ Tech Stack

  - [PHPStan homepage](https://phpstan.org/).
  - [PHPStan @ GitHub](https://github.com/phpstan/phpstan).

  ### 🧩 PHPStan rules

  - [phpstan/phpstan-deprecation-rules @ GitHub](https://github.com/phpstan/phpstan-deprecation-rules).
  - [Doctrine extensions for PHPStan @ GitHub](https://github.com/phpstan/phpstan-doctrine).
  - [PHPStan PHPUnit extensions and rules @ GitHub](https://github.com/phpstan/phpstan-phpunit).
  - [Extra strict and opinionated rules for PHPStan @ GitHub](https://github.com/phpstan/phpstan-strict-rules).
  - [PHPStan Symfony Framework extensions and rules @ GitHub](https://github.com/phpstan/phpstan-symfony).
  - [Rector Type Perfect @ GitHub](https://github.com/rectorphp/type-perfect).
  - [Symplify's PHPStan Rules](https://github.com/symplify/phpstan-rules).

  ### 🧑‍💻 Visual Studio Code

  - [phpstan @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=SanderRonde.phpstan-vscode).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.phpstan @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphpstan).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{
  config,
  lib,
  php-recipe-lib,
  recipes-lib,
  ...
}:
let
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (php-recipe-lib) mkPhpToolTasks mkVendorResetGoTask;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.attrsets) optionalAttrs;

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.phpstan;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/phpstan/vendor/phpstan/phpstan/phpstan";
  toolConfiguration = {
    name = "PHPStan";
    namespace = "phpstan";
    composerJsonPath = ../../../files/php/tools/phpstan/composer.json;
    configFiles = {
      "phpstan.dist.neon" = ../../../files/php/phpstan.dist.neon;
      "tests/PHPStan" = ../../../files/php/tests/PHPStan;
    };
    ignoredPaths = [ "phpstan.neon" ];
  };
in
{
  options.biapy-recipes.php.tools.phpstan = mkToolOptions phpToolsCfg "phpstan";

  config = mkIf cfg.enable {
    scripts = {
      phpstan = {
        description = "PHPStan";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "PHPStan is not installed."
            exit 1
          fi

          ${phpCommand} '${toolCommand}' "''${@}"
        '';
      };
    };

    languages.php = {
      extensions = [
        "ctype" # required by rector/type-perfect
        "simplexml" # required by phpstan/phpstan-symfony
      ];
    };

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "SanderRonde.phpstan-vscode" ];

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:lint:php:phpstan" = {
          description = "Lint '.php' files with PHPStan";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${phpCommand} '${toolCommand}' 'analyse' --no-progress
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:phpstan" = {
          aliases = [ "phpstan" ];
          desc = "Lint '*.php' files with PHPStan";
          cmds = [ "phpstan 'analyse' --no-progress" ];
          requires.vars = [ "DEVENV_ROOT" ];
        };
      }
      // mkVendorResetGoTask toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      phpstan = {
        enable = mkDefault true;
        name = "PHPStan";
        inherit (config.languages.php) package;
        pass_filenames = false;
        entry = ''${phpCommand} '${toolCommand}' "analyse"'';
        args = [ "--no-progress" ];
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
