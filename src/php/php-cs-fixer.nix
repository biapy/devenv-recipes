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
  tasks =
    {
      "ci:lint:php:php-cs-fixer".exec = ''
        set -o 'errexit' -o 'pipefail'

        cd "''${DEVENV_ROOT}"
        '${config.languages.php.package}/bin/php' 'vendor/bin/php-cs-fixer' 'analyse';
      '';
    }
    // utils.composer-bin.initializeComposerJsonTask composerBinTool
    // utils.composer-bin.initializeConfigFilesTask composerBinTool
    // utils.composer-bin.installTask composerBinTool
    // utils.tasks.gitIgnoreTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.php-cs-fixer = rec {
    enable = true;
    name = "PHPStan";
    inherit (config.languages.php) package;
    pass_filenames = false;
    entry = ''"${package}/bin/php" "''${DEVENV_ROOT}/vendor/bin/php-cs-fixer" "analyse"'';
    args = [ "--memory-limit=256m" ];
  };

  # See full reference at https://devenv.sh/reference/options/
}
