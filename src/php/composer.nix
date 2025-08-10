/**
  # Composer

  Composer is a dependency manager for PHP,
  allowing to manage libraries and packages in PHP projects.

  ## 🛠️ Tech Stack

  - [Composer homepage](https://getcomposer.org/).
  - [GNU Parallel homepage](https://www.gnu.org/software/parallel/).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [Setting priorities @ NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-option-definitions-setting-priorities).
*/
{
  pkgs,
  config,
  lib,
  ...
}:
let
  utils = import ../utils { inherit config; };
  inherit (config.languages.php.packages) composer;
  composerCommand = lib.meta.getExe composer;
  inherit (pkgs) parallel;
  parallelCommand = lib.meta.getExe parallel;
in
{
  imports = [
    ../gnu-parallel.nix
    ./php.nix
  ];

  languages.php = {
    enable = true;
    extensions = [
      "curl"
      "filter"
      "iconv"
      "mbstring"
      "openssl"
    ];
  };

  enterShell = ''
    export PATH="${config.env.DEVENV_ROOT}/vendor/bin:${config.env.DEVENV_ROOT}/bin:$PATH"
  '';

  # https://devenv.sh/tasks/
  tasks =
    {
      "devenv-recipes:enterShell:install:composer" = {
        description = "Install composer packages";
        before = [ "devenv:enterShell" ];
        exec = ''
          set -o 'errexit'
          [[ -e "''${DEVENV_ROOT}/composer.json" ]] &&
          ${composerCommand} 'install'
        '';
      };
    }
    // utils.tasks.gitIgnoreTask {
      name = "Composer";
      namespace = "composer";
      ignoredPaths = [ "/vendor/" ];
    };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    composer-validate = rec {
      enable = true;
      name = "composer validate";
      package = composer;
      extraPackages = [ parallel ];
      files = "composer\.(json|lock)$";
      entry = ''"${parallelCommand}" "${lib.meta.getExe package}" validate --no-check-publish {} ::: '';
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };

    composer-audit = rec {
      enable = true;
      name = "composer audit";
      after = [ "composer-validate" ];
      package = composer;
      extraPackages = [ parallel ];
      files = "composer\.(json|lock)$";
      verbose = true;
      entry = ''"${parallelCommand}" "${lib.meta.getExe package}" --working-dir="''${DEVENV_ROOT}" audit ::: '';
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
