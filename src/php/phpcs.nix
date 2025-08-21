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

  - `ci:lint:php:phpcs`: Lint PHP files with `phpcs`.
  - `devenv-recipes:reset:php:composer-bin:phpcs`: Delete 'vendor-bin/phpcs/vendor' folder.

  ### 👷 Commit hooks

  - `phpcs`: Lint PHP files with `phpcs`.

  ## 🛠️ Tech Stack

  - [PHP_CodeSniffer @ GitHub](https://github.com/PHPCSStandards/PHP_CodeSniffer).

  ### 🧩 PHP CodeSniffer plugins

  - [Slevomat Coding Standard @ GitHub](https://github.com/slevomat/coding-standard).
  - [PHPCompatibility @ GitHub](https://github.com/PHPCompatibility/PHPCompatibility).
  - [PHP_CodeSniffer Standards Composer Installer Plugin @ GitHub](https://github.com/PHPCSStandards/composer-installer).
  - [Symfony PHP CodeSniffer Coding Standard @ GitHub](https://github.com/djoos/Symfony-coding-standard).
  - [GitLab Report for PHP_CodeSniffer @ GitHub](https://github.com/micheh/phpcs-gitlab).

  ### Visual Studio Code

  - [PHP Sniffer & Beautifier @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ValeryanM.vscode-phpsab).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.phpcs @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphpcs).
  - [git-hooks.hooks.phpcbf @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphpcbf).
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
  phpcsCommand = "${root}/vendor-bin/phpcs/vendor/squizlabs/php_codesniffer/bin/phpcs";
  composerBinTool = {
    name = "PHP CodeSniffer";
    namespace = "phpcs";
    composerJsonPath = ../files/php/vendor-bin/phpcs/composer.json;
    configFiles = {
      ".phpcs.xml.dist" = ../files/php/.phpcs.xml.dist;
    };
    ignoredPaths = [
      "phpcs.xml"
      ".phpcs.xml"
      ".phpcs.cache"
    ];
  };
in
{
  imports = [ ./composer-bin.nix ];

  # https://devenv.sh/integrations/codespaces-devcontainer/
  devcontainer.settings.customizations.vscode.extensions = [ "ValeryanM.vscode-phpsab" ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:php:phpcs" = {
      description = "Lint '.php' files with PHP CodeSniffer";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${phpCommand} '${phpcsCommand}' --colors
      '';
    };
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool
  // utils.composer-bin.resetTask composerBinTool
  // utils.tasks.gitIgnoreTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.phpcs = {
    enable = true;
    name = "PHP CodeSniffer";
    inherit (config.languages.php) package;
    entry = "${phpCommand} '${phpcsCommand}'";
    args = [ "-q" ];
  };

  # See full reference at https://devenv.sh/reference/options/
}
