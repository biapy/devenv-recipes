/**
  # Twig CS Fixer

  Twig CS Fixer is a tool to automatically fix Twig Coding Standards issues.

  ## 🛠️ Tech Stack

  - [Twig CS Fixer @ GitHub](https://github.com/VincentLanglet/Twig-CS-Fixer).
*/
{ config, ... }:
let
  utils = import ../utils { inherit config; };
  composerBinTool = {
    name = "Twig CS Fixer";
    namespace = "twig-cs-fixer";
    composerJsonPath = ./files/vendor-bin/twig-cs-fixer/composer.json;
    configFiles = {
      ".twig-cs-fixer.dist.php" = ./files/.twig-cs-fixer.dist.php;
    };
  };
in
{
  imports = [ ./composer-bin.nix ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:format:twig:twig-cs-fixer" = {
      description = "Apply Twig CS Fixer recommendations";
      exec = ''
        set -o 'errexit'

        cd "''${DEVENV_ROOT}"
        '${config.languages.php.package}/bin/php' 'vendor/bin/twig-cs-fixer' 'lint' --fix;
      '';
    };
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool;

  # See full reference at https://devenv.sh/reference/options/
}
