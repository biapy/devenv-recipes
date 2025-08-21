/**
  # PHP Mess Detector

  `phpmd` takes a given PHP source code base and look for several potential
  problems within that source.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:phpmd`: Lint 'src' and 'tests' with PHP Mess Detector.
  - `devenv-recipes:reset:php:composer-bin:phpmd`: Delete 'vendor-bin/phpmd/vendor' folder.

  ### 👷 Commit hooks

  - `phpmd`: Lint 'src' and 'tests' with PHP Mess Detector.

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
  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  phpmdCommand = "${root}/vendor-bin/phpmd/vendor/phpmd/phpmd/src/bin/phpmd";
  inherit (pkgs) parallel;
  parallelCommand = lib.meta.getExe parallel;
  composerBinTool = {
    name = "PHP Mess Detector";
    namespace = "phpmd";
    composerJsonPath = ../files/php/vendor-bin/phpmd/composer.json;
    configFiles = {
      "phpmd.xml" = ../files/php/phpmd.xml;
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
        cd "''${DEVENV_ROOT}"
        ${phpCommand} -d 'error_reporting=~E_DEPRECATED' \
          '${phpmdCommand}' {src,tests} 'ansi' 'phpmd.xml'
      '';
    };
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool
  // utils.composer-bin.resetTask composerBinTool
  // utils.tasks.gitIgnoreTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.phpmd = {
    enable = true;
    name = "PHP Mess Detector";
    inherit (config.languages.php) package;
    extraPackages = [ parallel ];
    # Using parallel allows to run phpmd on staged files only
    entry = ''${parallelCommand} ${phpCommand} -d 'error_reporting=~E_DEPRECATED' '${phpmdCommand}' {} 'ansi' '${root}/phpmd.xml' ::: '';
  };

  # See full reference at https://devenv.sh/reference/options/
}
