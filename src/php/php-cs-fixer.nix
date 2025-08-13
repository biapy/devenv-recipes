{ pkgs, config, ... }:
let
  utils = import ../utils { inherit config; };
  composerBinTool = {
    name = "PHP Coding Standards Fixer";
    namespace = "php-cs-fixer";
    composerJsonPath = ./files/vendor-bin/php-cs-fixer/composer.json;
    configFiles = {
      ".php-cs-fixer.dist.php" = ./files/.php-cs-fixer.dist.php;
    };
    ignoredPaths = [
      ".php-cs-fixer.cache"
      ".php-cs-fixer.php"
    ];
  };
in
{
  imports = [ ./composer-bin.nix ];

  # https://devenv.sh/packages/
  packages = with pkgs; [ fd ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:php:php-cs-fixer".exec = ''
      set -o 'errexit'

      cd "''${DEVENV_ROOT}"
      '${config.languages.php.package}/bin/php' 'vendor/bin/php-cs-fixer' 'fix' --dry-run --diff --show-progress='bar';
    '';
    "ci:format:php:php-cs-fixer".exec = ''
      set -o 'errexit'

      cd "''${DEVENV_ROOT}"
      '${config.languages.php.package}/bin/php' 'vendor/bin/php-cs-fixer' 'fix' --diff --show-progress='bar';
    '';
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool
  // utils.tasks.gitIgnoreTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.php-cs-fixer = rec {
    enable = true;
    name = "PHP Coding Standards Fixer";
    inherit (config.languages.php) package;
    files = ".*\.php$";
    entry = "${package}/bin/php '${config.env.DEVENV_ROOT}/vendor/bin/php-cs-fixer' 'fix'";
    args = [ "--dry-run" ];
  };

  # See full reference at https://devenv.sh/reference/options/
}
