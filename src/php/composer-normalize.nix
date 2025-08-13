{ pkgs, config, ... }:
let
  utils = import ../utils { inherit config; };
  composerCommand = "${config.languages.php.packages.composer}/bin/composer";
  parallelCommand = "${pkgs.parallel}/bin/parallel";
  composerBinTool = {
    name = "composer normalize";
    namespace = "composer-normalize";
    composerJsonPath = ./files/vendor-bin/composer-normalize/composer.json;
  };
in
{
  imports = [
    ../gnu-parallel.nix
    ./composer-bin.nix
  ];

  # https://devenv.sh/packages/
  packages = with pkgs; [ fd ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:format:composer:composer-normalize" = {
      description = "Reorganize composer.json files with composer normalize";
      exec = ''
        set -o 'errexit' -o 'pipefail'

        cd "''${DEVENV_ROOT}"
        ${pkgs.fd}/bin/fd 'composer\.json$' "''${DEVENV_ROOT}" --exec '${composerCommand}' bin composer-normalize normalize {}
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
      package = config.languages.php.packages.composer;
      extraPackages = [ pkgs.parallel ];
      files = "composer.json";
      entry = ''"${parallelCommand}" '${package}/bin/composer' bin composer-normalize normalize --dry-run "''${DEVENV_ROOT}/"{} ::: '';
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
