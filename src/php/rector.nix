{ pkgs, config, ... }:
let
  utils = import ../utils { inherit config; };
  composerBinTool = {
    name = "Rector";
    namespace = "rector";
    composerJsonPath = ./files/vendor-bin/rector/composer.json;
    configFiles = {
      "rector.php" = ./files/rector.php;
    };
  };
in
{
  imports = [ ./composer-bin.nix ];

  # https://devenv.sh/packages/
  packages = with pkgs; [ fd ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:format:php:rector" = {
      description = "Apply Rector recommendations";
      exec = ''
        set -o 'errexit'

        cd "''${DEVENV_ROOT}"
        '${config.languages.php.package}/bin/php' 'vendor/bin/rector' 'process';
      '';
    };
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.rector = rec {
    enable = true;
    name = "Rector";
    inherit (config.languages.php) package;
    pass_filenames = false;
    entry = ''"${package}/bin/php" "''${DEVENV_ROOT}/vendor/bin/rector" "process"'';
    args = [ "--dry-run" ];
  };

  # See full reference at https://devenv.sh/reference/options/
}
