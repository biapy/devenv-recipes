/**
  # PHPStan

  `phpstan` on finding errors in your code without actually running it.

  ## 🛠️ Tech Stack

  - [PHPStan homepage](https://phpstan.org/).
  - [PHPStan @ GitHub](https://github.com/phpstan/phpstan).

  ### PHPStan rules

  - [phpstan/phpstan-deprecation-rules @ GitHub](https://github.com/phpstan/phpstan-deprecation-rules).
  - [Doctrine extensions for PHPStan @ GitHub](https://github.com/phpstan/phpstan-doctrine).
  - [PHPStan PHPUnit extensions and rules @ GitHub](https://github.com/phpstan/phpstan-phpunit).
  - [Extra strict and opinionated rules for PHPStan @ GitHub](https://github.com/phpstan/phpstan-strict-rules).
  - [PHPStan Symfony Framework extensions and rules @ GitHub](https://github.com/phpstan/phpstan-symfony).
  - [Rector Type Perfect @ GitHub](https://github.com/rectorphp/type-perfect).
  - [Symplify's PHPStan Rules](https://github.com/symplify/phpstan-rules).

  ### Visual Studio Code

  - [phpstan @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=SanderRonde.phpstan-vscode).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.phpstan @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphpstan).
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
  phpstanCommand = "${root}/vendor-bin/phpstan/vendor/bin/phpstan";
  composerBinTool = {
    name = "PHPStan";
    namespace = "phpstan";
    composerJsonPath = ../files/php/vendor-bin/phpstan/composer.json;
    configFiles = {
      "phpstan.dist.neon" = ../files/php/phpstan.dist.neon;
      "tests/PHPStan" = ../files/php/tests/PHPStan;
    };
    ignoredPaths = [ "phpstan.neon" ];
  };
in
{
  imports = [ ./composer-bin.nix ];

  languages.php = {
    extensions = [
      "ctype" # required by rector/type-perfect
      "simplexml" # required by phpstan/phpstan-symfony
    ];
  };

  # https://devenv.sh/integrations/codespaces-devcontainer/
  devcontainer.settings.customizations.vscode.extensions = [ "SanderRonde.phpstan-vscode" ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:php:phpstan".exec = ''
      set -o 'errexit' -o 'pipefail'

      cd "''${DEVENV_ROOT}"
      ${phpCommand} '${phpstanCommand}' 'analyse' --no-progress;
    '';
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool
  // utils.tasks.gitIgnoreTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.phpstan = {
    enable = true;
    name = "PHPStan";
    inherit (config.languages.php) package;
    pass_filenames = false;
    entry = ''${phpCommand} '${phpstanCommand}' "analyse"'';
    args = [ "--no-progress" ];
  };

  # See full reference at https://devenv.sh/reference/options/
}
