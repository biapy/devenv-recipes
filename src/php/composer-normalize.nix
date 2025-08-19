/**
  # ergebnis/composer-normalize

  `ergebnis/composer-normalize` provides a `composer` plugin for normalizing
  `composer.json`.

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
        set -o 'errexit' -o 'pipefail'

        cd "''${DEVENV_ROOT}"
        ${fdCommand} 'composer\.json$' "''${DEVENV_ROOT}" --exec '${composerCommand}' bin composer-normalize normalize {}
      '';
    };
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.installTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    composer-normalize = rec {
      enable = true;
      name = "composer normalize";
      before = [ "composer-validate" ];
      package = composer;
      extraPackages = [ parallel ];
      files = "composer.json";
      entry = ''"${parallelCommand}" '${package}/bin/composer' bin composer-normalize normalize --dry-run "''${DEVENV_ROOT}/"{} ::: '';
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
