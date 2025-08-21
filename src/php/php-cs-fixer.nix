/**
  # PHP Coding Standard Fixer

  `php-cs-fixer` is a tool to automatically fix PHP Coding Standards issues

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:php-cs-fixer`: Lint PHP files with `php-cs-fixer`.
  - `ci:format:php:php-cs-fixer`: Format PHP files with `php-cs-fixer`.

  ### 👷 Commit hooks

  - `php-cs-fixer`: Lint PHP files with `php-cs-fixer`.
  - `devenv-recipes:reset:php:composer-bin:php-cs-fixer`: Delete 'vendor-bin/php-cs-fixer/vendor' folder.

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
{ config, lib, ... }:
let
  utils = import ../utils {
    inherit config;
    inherit lib;
  };
  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  phpCsFixerCommand = "${root}/vendor-bin/php-cs-fixer/vendor/friendsofphp/php-cs-fixer/php-cs-fixer";
  composerBinTool = {
    name = "PHP Coding Standards Fixer";
    namespace = "php-cs-fixer";
    composerJsonPath = ../files/php/vendor-bin/php-cs-fixer/composer.json;
    configFiles = {
      ".php-cs-fixer.dist.php" = ../files/php/.php-cs-fixer.dist.php;
    };
    ignoredPaths = [
      ".php-cs-fixer.cache"
      ".php-cs-fixer.php"
    ];
  };
in
{
  imports = [ ./composer-bin.nix ];

  # https://devenv.sh/integrations/codespaces-devcontainer/
  devcontainer.settings.customizations.vscode.extensions = [ "junstyle.php-cs-fixer" ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:php:php-cs-fixer".exec = ''
      cd "''${DEVENV_ROOT}"
      ${phpCommand} '${phpCsFixerCommand}' 'fix' --allow-unsupported-php-version=yes \
        --no-interaction --diff --show-progress='none' --dry-run;
    '';
    "ci:format:php:php-cs-fixer".exec = ''
      cd "''${DEVENV_ROOT}"
      ${phpCommand} '${phpCsFixerCommand}' 'fix' --allow-unsupported-php-version=yes \
        --no-interaction --diff --show-progress='none';
    '';
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool
  // utils.composer-bin.resetTask composerBinTool
  // utils.tasks.gitIgnoreTask composerBinTool;

  # https://devenv.sh/git-hooks/
  # https://cs.symfony.com/doc/usage.html#using-php-cs-fixer-on-ci
  git-hooks.hooks.php-cs-fixer = {
    enable = true;
    name = "PHP Coding Standards Fixer";
    inherit (config.languages.php) package;
    files = "^(\.php-cs-fixer(\.dist)?\.php|composer\.lock)$";
    entry = ''${phpCommand} '${phpCsFixerCommand}' fix'';
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
}
