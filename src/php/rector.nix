/**
  # Rector

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:rector`: Lint '.php' files with Rector.
  - `ci:format:php:rector`: Apply Rector recommendations.
  - `devenv-recipes:reset:php:composer-bin:rector`: Delete 'vendor-bin/rector/vendor' folder.

  ### 👷 Commit hooks

  - `rector`: Lint '.php' files with Rector.

  ## 🛠️ Tech Stack

  - [Rector homepage](https://getrector.com/)
    ([Rector @ GitHub](https://github.com/rectorphp/rector)).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/

{ config, lib, ... }:
let
  utils = import ../utils {
    inherit config;
    inherit lib;
  };
  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  rectorCommand = "${root}/vendor-bin/rector/vendor/rector/rector/bin/rector";
  composerBinTool = {
    name = "Rector";
    namespace = "rector";
    composerJsonPath = ../files/php/vendor-bin/rector/composer.json;
    configFiles = {
      "rector.php" = ../files/php/rector.php;
    };
  };
in
{
  imports = [ ./composer-bin.nix ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:format:php:rector" = {
      description = "Apply Rector recommendations";
      before = [ "ci:format:php:php-cs-fixer" ];
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${phpCommand} '${rectorCommand}' 'process' '--no-progress-bar';
      '';
    };
    "ci:lint:php:rector" = {
      description = "Lint '.php' files with Rector";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${phpCommand} '${rectorCommand}' 'process' '--no-progress-bar' '--dry-run';
      '';
    };
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool
  // utils.composer-bin.resetTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.rector = {
    enable = true;
    name = "Rector";
    inherit (config.languages.php) package;
    pass_filenames = false;
    entry = ''${phpCommand} '${rectorCommand}' "process"'';
    args = [
      "--no-progress-bar"
      "--dry-run"
    ];
  };

  # See full reference at https://devenv.sh/reference/options/
}
