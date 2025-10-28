/**
  # PHP CodeSniffer

  _PHP CodeSniffer_ is a set of two PHP scripts; the main `phpcs` script that
  inspects PHP, JavaScript and CSS files to detect violations of a defined
  coding standard, and a second `phpcbf` script to automatically correct coding
  standard violations.
  PHP CodeSniffer is an essential development tool that ensures your code
  remains clean and consistent.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:phpcs`: 🔍 Lint 🐘PHP files with `phpcs`.
  - `reset:php:tools:phpcs`: Delete 'phpcs/vendor' folder.

  ### 👷 Commit hooks

  - `phpcs`: 🔍 Lint 🐘PHP files with `phpcs`.

  ## 🛠️ Tech Stack

  - [PHP_CodeSniffer @ GitHub](https://github.com/PHPCSStandards/PHP_CodeSniffer).

  ### 🧩 PHP CodeSniffer plugins

  - [Slevomat Coding Standard @ GitHub](https://github.com/slevomat/coding-standard).
  - [PHPCompatibility @ GitHub](https://github.com/PHPCompatibility/PHPCompatibility).
  - [PHP_CodeSniffer Standards Composer Installer Plugin @ GitHub](https://github.com/PHPCSStandards/composer-installer).
  - [Symfony PHP CodeSniffer Coding Standard @ GitHub](https://github.com/djoos/Symfony-coding-standard).
  - [GitLab Report for PHP_CodeSniffer @ GitHub](https://github.com/micheh/phpcs-gitlab).

  ### 🧑‍💻 Visual Studio Code

  - [PHP Sniffer & Beautifier @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ValeryanM.vscode-phpsab).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.phpcs @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphpcs).
  - [git-hooks.hooks.phpcbf @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphpcbf).
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

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.phpcs;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/phpcs/vendor/squizlabs/php_codesniffer/bin/phpcs";
  phpcbfCommand = "${root}/${phpToolsCfg.path}/phpcs/vendor/squizlabs/php_codesniffer/bin/phpcbf";
  toolConfiguration = {
    name = "PHP CodeSniffer";
    namespace = "phpcs";
    composerJsonPath = ../../../files/php/tools/phpcs/composer.json;
    configFiles = {
      ".phpcs.xml.dist" = ../../../files/php/.phpcs.xml.dist;
    };
    ignoredPaths = [
      "phpcs.xml"
      ".phpcs.xml"
      ".phpcs.cache"
    ];
  };
in
{
  options.biapy-recipes.php.tools.phpcs = mkToolOptions phpToolsCfg "phpcs";

  config = mkIf cfg.enable {
    scripts = {
      phpcs = {
        description = "PHP CodeSniffer";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "PHP CodeSniffer is not installed."
            exit 1
          fi

          ${phpCommand} '${toolCommand}' "''${@}"
        '';
      };

      phpcbf = {
        description = "PHP Code Beautifier and Fixer";
        exec = ''
            if [[ ! -e '${phpcbfCommand}' ]]; then
            echo "PHP Code Beautifier and Fixer is not installed."
            exit 1
          fi

          ${phpCommand} '${phpcbfCommand}' "''${@}"
        '';
      };
    };

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "ValeryanM.vscode-phpsab" ];

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:lint:php:phpcs" = {
          description = "🔍 Lint 🐘PHP files with PHP CodeSniffer";
          exec = ''
            cd "''${DEVENV_ROOT}"
            phpcs --colors
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:phpcs" = patchGoTask {
          aliases = [ "phpcs" ];
          desc = "🔍 Lint 🐘PHP files with PHP CodeSniffer";
          cmds = [ ''phpcs --colors'' ];
        };
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      phpcs = {
        enable = mkDefault true;
        name = "PHP CodeSniffer";
        inherit (config.languages.php) package;
        entry = "phpcs";
        args = [ "-q" ];
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
