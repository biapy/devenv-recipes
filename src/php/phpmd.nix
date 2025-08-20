/**
  # PHP Mess Detector

  `phpmd` takes a given PHP source code base and look for several potential
  problems within that source.

  ## 🛠️ Tech Stack

  - [PHP Mess Detector homepage](https://phpmd.org/).
  - [PHP Mess Detector @ GitHub](https://github.com/phpmd/phpmd).

  ### Visual Studio Code

  - [PHP Mess Detector @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ecodes.vscode-phpmd).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
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
  phpCommand = lib.meta.getExe config.languages.php.package;
  inherit (pkgs) parallel;
  parallelCommand = lib.meta.getExe parallel;
  composerBinTool = {
    name = "PHP Mess Detector";
    namespace = "phpmd";
    composerJsonPath = ../files/php/vendor-bin/phpmd/composer.json;
    configFiles = {
      "phpmd.xml.dist" = ../files/php/phpmd.xml.dist;
    };
    ignoredPaths = [ "/.phpmd.result-cache.php" ];
  };
in
{
  imports = [
    ../gnu-parallel.nix
    ./composer-bin.nix
  ];

  # https://devenv.sh/integrations/codespaces-devcontainer/
  devcontainer.settings.customizations.vscode.extensions = [ "ecodes.vscode-phpmd" ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:php:phpmd" = {
      description = "Lint 'src' and 'tests' with PHP Mess Detector";
      exec = ''
        set -o 'errexit'
        cd "''${DEVENV_ROOT}"
        ${phpCommand} -d 'error_reporting=~E_DEPRECATED' 'vendor/bin/phpmd' {src,tests} 'ansi' 'phpmd.xml.dist'
      '';
    };
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.phpmd = {
    enable = true;
    name = "PHP Mess Detector";
    inherit (config.languages.php) package;
    extraPackages = [ parallel ];
    entry = ''${parallelCommand} ${phpCommand} -d 'error_reporting=~E_DEPRECATED' "''${DEVENV_ROOT}/vendor/bin/phpmd" {} 'ansi' "''${DEVENV_ROOT}/phpmd.xml.dist" ::: '';
  };

  # See full reference at https://devenv.sh/reference/options/
}
