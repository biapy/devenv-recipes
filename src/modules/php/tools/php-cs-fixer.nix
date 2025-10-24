/**
  # PHP Coding Standard Fixer

  `php-cs-fixer` is a tool to automatically fix PHP Coding Standards issues

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:php-cs-fixer`: 🔍 Lint 🐘PHP files with `php-cs-fixer`.
  - `ci:format:php:php-cs-fixer`: 🎨 Format 🐘PHP files with `php-cs-fixer`.

  ### 👷 Commit hooks

  - `php-cs-fixer`: 🔍 Lint 🐘PHP files with `php-cs-fixer`.
  - `reset:php:tools:php-cs-fixer`: Delete 'php-cs-fixer/vendor' folder.

  ## 🛠️ Tech Stack

  - [PHP Coding Standard Fixer homepage](https://cs.symfony.com/).
  - [PHP Coding Standard Fixer @ GitHub](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer).

  ### 🧑‍💻 Visual Studio Code

  - [php cs fixer @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=junstyle.php-cs-fixer).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.php-cs-fixer @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphp-cs-fixer).
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
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (php-recipe-lib) mkPhpToolTasks mkPhpToolGoTasks;
  inherit (config.devenv) root;

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.php-cs-fixer;

  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/php-cs-fixer/vendor/friendsofphp/php-cs-fixer/php-cs-fixer";
  toolConfiguration = {
    name = "PHP Coding Standards Fixer";
    namespace = "php-cs-fixer";
    composerJsonPath = ../../../files/php/tools/php-cs-fixer/composer.json;
    configFiles = {
      ".php-cs-fixer.dist.php" = ../../../files/php/.php-cs-fixer.dist.php;
    };
    ignoredPaths = [
      ".php-cs-fixer.cache"
      ".php-cs-fixer.php"
    ];
  };
in
{
  options.biapy-recipes.php.tools.php-cs-fixer = mkToolOptions phpToolsCfg "php-cs-fixer";

  config = mkIf cfg.enable {

    scripts = {
      php-cs-fixer = {
        description = "PHP Coding Standards Fixer";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "PHP Coding Standards Fixer is not installed."
            exit 1
          fi

          ${phpCommand} '${toolCommand}' "''${@}"
        '';
      };
    };

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "junstyle.php-cs-fixer" ];

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:lint:php:php-cs-fixer".exec = ''
          cd "''${DEVENV_ROOT}"
          php-cs-fixer 'fix' --allow-unsupported-php-version=yes \
            --no-interaction --diff --show-progress='none' --dry-run
        '';
        "ci:format:php:php-cs-fixer".exec = ''
          cd "''${DEVENV_ROOT}"
          php-cs-fixer 'fix' --allow-unsupported-php-version=yes \
            --no-interaction --diff --show-progress='none'
        '';
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:format:php:php-cs-fixer" = patchGoTask {
          aliases = [ "php-cs-fixer" ];
          desc = "🎨 Format 🐘PHP files with php-cs-fixer";
          cmds = [
            "php-cs-fixer 'fix' --allow-unsupported-php-version=yes --no-interaction --diff --show-progress='none'"
          ];
        };

        "ci:lint:php:php-cs-fixer" = patchGoTask {
          desc = "🔍 Lint 🐘PHP files with php-cs-fixer";
          cmds = [
            "php-cs-fixer 'fix' --allow-unsupported-php-version=yes --no-interaction --diff --show-progress='none' --dry-run"
          ];
        };
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    # https://cs.symfony.com/doc/usage.html#using-php-cs-fixer-on-ci
    git-hooks.hooks.php-cs-fixer = optionalAttrs cfg.go-task {
      enable = mkDefault true;
      name = "PHP Coding Standards Fixer";
      inherit (config.languages.php) package;
      files = "^(\.php-cs-fixer(\.dist)?\.php|composer\.lock)$";
      entry = ''${phpCommand} '${toolCommand}' fix'';
      args = [
        "--no-interaction"
        "--diff"
        "--show-progress=none"
        "--path-mode=intersection"
        "--verbose"
        "--stop-on-violation"
        "--using-cache=no"
        "--dry-run"
        "--"
      ];
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
