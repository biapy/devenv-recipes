/**
  # Symfony

  Symfony is a powerful PHP framework that empowers developers to build
  scalable, high-performance web applications with reusable components,
  comprehensive documentation, and a strong community.

  ## 🛠️ Tech Stack

  - [Symfony homepage](https://symfony.com/).

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
  inherit (pkgs) symfony-cli;
  symfonyCommand = lib.meta.getExe symfony-cli;
in
{
  imports = [ ./composer.nix ];

  languages.php = {
    enable = true;
    extensions = [
      "dom"
      "pdo_pgsql"
    ];
  };

  enterShell = ''
    export PATH="${config.env.DEVENV_ROOT}/vendor/bin:${config.env.DEVENV_ROOT}/bin:$PATH"
  '';

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:symfony:container" = {
      description = "Lint services containerwith Symfony console";
      exec = ''
        set -o 'errexit'
        cd "''${DEVENV_ROOT}"
        '${symfonyCommand}' console 'lint:container'
      '';
    };

    "ci:lint:twig:symfony" = {
      description = "Lint 'twig' files with Symfony console";
      exec = ''
        set -o 'errexit'
        cd "''${DEVENV_ROOT}"
        '${symfonyCommand}' console 'lint:twig' '--show-deprecations'
      '';
    };
    "ci:lint:xliff:symfony" = {
      description = "Lint 'xlf' files with Symfony console";
      exec = ''
        set -o 'errexit'
        cd "''${DEVENV_ROOT}"
        '${symfonyCommand}' console 'lint:xliff'
      '';
    };
    "ci:lint:yaml:symfony" = {
      description = "Lint 'yml' files with Symfony console";
      exec = ''
        set -o 'errexit'
        cd "''${DEVENV_ROOT}"
        '${symfonyCommand}' console 'lint:yaml'
      '';
    };
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    symfony-lint-container = rec {
      enable = true;
      name = "symfony lint container";
      package = symfony-cli;
      files = "\.(php|yml|yaml)$";
      pass_filenames = false;
      entry = ''"${lib.meta.getExe package}" console lint:container'';
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };

    symfony-lint-twig = rec {
      enable = true;
      name = "symfony lint:twig";
      package = symfony-cli;
      files = "\.twig$";
      entry = ''"${lib.meta.getExe package}" console lint:twig'';
      args = [ "--show-deprecations" ];
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };

    symfony-lint-xliff = rec {
      enable = true;
      name = "symfony lint:xliff";
      package = symfony-cli;
      files = "\.xlf$";
      entry = ''"${lib.meta.getExe package}" console lint:xliff'';
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };

    symfony-lint-yaml = rec {
      enable = true;
      name = "symfony lint:yaml";
      package = symfony-cli;
      files = "\.(yml|yaml)$";
      entry = ''"${lib.meta.getExe package}" console lint:yaml'';
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
