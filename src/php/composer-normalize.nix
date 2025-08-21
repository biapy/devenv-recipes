/**
  # ergebnis/composer-normalize

  `ergebnis/composer-normalize` provides a `composer` plugin for normalizing
  `composer.json`.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:format:php:composer-normalize`: Reorganize `composer.json` files
    with `composer normalize`.
  - `devenv-recipes:reset:php:composer-bin:composer-normalize`: Delete 'vendor-bin/composer-normalize/vendor' folder.

  ### 👷 Commit hooks

  - `composer-normalize`: Reorganize `composer.json` files with
    `composer normalize`.

  ## 🛠️ Tech Stack

  - [ergebnis/composer-normalize @ GitHub](https://github.com/ergebnis/composer-normalize)

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
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
  inherit (config.languages.php.packages) composer;
  composerCommand = lib.meta.getExe composer;
  inherit (pkgs) parallel fd;
  parallelCommand = lib.meta.getExe parallel;
  fdCommand = lib.meta.getExe fd;
  composerBinTool = {
    name = "composer normalize";
    namespace = "composer-normalize";
    composerJsonPath = ../files/php/vendor-bin/composer-normalize/composer.json;
  };
in
{
  imports = [
    ../gnu-parallel.nix
    ./composer-bin.nix
  ];

  # https://devenv.sh/packages/
  packages = [ fd ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:format:composer:composer-normalize" = {
      description = "Reorganize composer.json files with composer normalize";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${fdCommand} '^composer\.json$' "''${DEVENV_ROOT}" --exec \
          '${composerCommand}' bin composer-normalize normalize {}
      '';
    };
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.installTask composerBinTool
  // utils.composer-bin.resetTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    composer-normalize = {
      enable = true;
      name = "composer normalize";
      before = [ "composer-validate" ];
      package = composer;
      extraPackages = [ parallel ];
      files = "composer.json";
      entry = ''"${parallelCommand}" '${composerCommand}' bin composer-normalize normalize --dry-run "${root}/"{} ::: '';
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
