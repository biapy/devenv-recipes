{
  pkgs,
  config,
  lib,
  ...
}:
let
  utils = import ../utils {
    inherit config;
    inherit lib;
  };
  composerBinTool = {
    name = "PHPStan";
    namespace = "phpstan";
    composerJsonPath = ./files/vendor-bin/phpstan/composer.json;
    configFiles = {
      "phpstan.dist.neon" = ./files/phpstan.dist.neon;
    };
    ignoredPaths = [ "phpstan.neon" ];
  };
in
{
  imports = [ ./composer-bin.nix ];

  # https://devenv.sh/packages/
  packages = with pkgs; [ fd ];

  languages.php = {
    enable = true;
    extensions = [
      "ctype" # required by rector/type-perfect
      "simplexml" # required by phpstan/phpstan-symfony
    ];
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:php:phpstan".exec = ''
      set -o 'errexit' -o 'pipefail'

      cd "''${DEVENV_ROOT}"
      '${config.languages.php.package}/bin/php' 'vendor/bin/phpstan' 'analyse';
    '';
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool
  // utils.tasks.gitIgnoreTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.phpstan = rec {
    enable = true;
    name = "PHPStan";
    inherit (config.languages.php) package;
    pass_filenames = false;
    entry = ''"${package}/bin/php" "''${DEVENV_ROOT}/vendor/bin/phpstan" "analyse"'';
    args = [ "--memory-limit=256m" ];
  };

  # See full reference at https://devenv.sh/reference/options/
}
