/**
  # TwigStan

   TwigStan is a static analyzer for Twig templates powered by PHPStan.

   ## 🛠️ Tech Stack

   - [TwigStan @ GitHub](https://github.com/twigstan/twigstan).
*/
{ config, ... }:
let
  utils = import ../utils { inherit config; };
  composerBinTool = {
    name = "TwigStan";
    namespace = "twigstan";
    composerJsonPath = ./files/vendor-bin/twigstan/composer.json;
    configFiles = {
      "twigstan.php" = ./files/twigstan.php;
      "tests/twig-loader.php" = ./files/twig-loader.php;
    };
  };
in
{
  imports = [ ./composer-bin.nix ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:twig:twigstan" = {
      description = "Lint twig files with TwigStan";
      exec = ''
        set -o 'errexit'

        cd "''${DEVENV_ROOT}"
        '${config.languages.php.package}/bin/php' 'vendor/bin/twigstan';
      '';
    };
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool;

  # See full reference at https://devenv.sh/reference/options/
}
