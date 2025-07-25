{ pkgs, config, ... }:
let
  utils = import ../utils { inherit config; };
  composerBinTool = {
    name = "PHPStan";
    namespace = "phpstan";
    composerJsonPath = ./files/vendor-bin/phpstan/composer.json;
    configFiles = {
      "phpstan.dist.neon" = ./files/phpstan.dist.neon;
    };
  };
in
{
  imports = [ ./composer-bin.nix ];

  # https://devenv.sh/packages/
  packages = with pkgs; [ fd ];

  # https://devenv.sh/tasks/
  tasks =
    {
      "ci:lint:php:phpstan".exec = ''
        set -o 'errexit' -o 'pipefail'

        cd "''${DEVENV_ROOT}"
        '${config.languages.php.package}/bin/php' 'vendor/bin/phpstan' 'analyse';
      '';
    }
    // utils.composer-bin.initializeComposerJsonTask composerBinTool
    // utils.composer-bin.initializeConfigFilesTask composerBinTool
    // utils.composer-bin.installTask composerBinTool;

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
