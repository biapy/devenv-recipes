/**
  # Symfony

  Symfony is a powerful PHP framework that empowers developers to build
  scalable, high-performance web applications with reusable components,
  comprehensive documentation, and a strong community.

  ## 🛠️ Tech Stack

  - [Symfony homepage](https://symfony.com/).
  - [fd @ GitHub](https://github.com/sharkdp/fd).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [lib.strings.isString @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.isString).
  - [Operators @ Nix 2.28.5 Reference Manual](https://nix.dev/manual/nix/2.28/language/operators.html).
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
  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
in
{
  imports = [
    ../dotenv.nix
    ./composer.nix
    ./phpstan.nix
  ];

  packages = [ fd ];

  languages.php = {
    enable = true;
    extensions = [
      "dom"
      "pdo_pgsql"
    ];
  };

  # Load symfony .env.dev environment
  dotenv.filename = [ ".env.dev" ];

  enterShell = ''
    export PATH="${config.env.DEVENV_ROOT}/vendor/bin:${config.env.DEVENV_ROOT}/bin:$PATH"
  '';

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:symfony:container" = {
      description = "Lint services container with Symfony console";
      exec = ''
        set -o 'errexit'
        cd "''${DEVENV_ROOT}"
        ${symfonyCommand} console 'lint:container'
      '';
    };

    "ci:lint:twig:symfony" = {
      description = "Lint 'twig' files with Symfony console";
      exec = ''
        set -o 'errexit'
        cd "''${DEVENV_ROOT}"
        ${fdCommand} --extension='twig' --type='file' --exec-batch \
            ${symfonyCommand} console 'lint:twig' '--show-deprecations'
      '';
    };

    "ci:lint:xliff:symfony" = {
      description = "Lint 'xlf' files with Symfony console";
      exec = ''
        set -o 'errexit'
        cd "''${DEVENV_ROOT}"
        ${fdCommand} --extension='xlf' --type='file' --exec-batch \
          ${symfonyCommand} console 'lint:xliff'
      '';
    };

    "ci:lint:yaml:symfony" = {
      description = "Lint 'yml' files with Symfony console";
      exec = ''
        set -o 'errexit'
        cd "''${DEVENV_ROOT}"
        ${fdCommand} --extension='yml' --extension='yaml' --type='file' --exec-batch \
            ${symfonyCommand} console 'lint:yaml'
      '';
    };
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    symfony-lint-container = {
      enable = true;
      name = "symfony lint container";
      package = symfony-cli;
      files = "\.(php|yml|yaml|xml|json|lock)$";
      pass_filenames = false;
      entry = ''"${symfonyCommand}" console lint:container'';
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };

    symfony-lint-twig = {
      enable = true;
      name = "symfony lint:twig";
      package = symfony-cli;
      files = "\.twig$";
      entry = ''${symfonyCommand} console lint:twig'';
      args = [ "--show-deprecations" ];
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };

    symfony-lint-translations = {
      enable = true;
      name = "symfony lint:translations";
      package = symfony-cli;
      files = "/translations/.*\.(php|xlf|yml|yaml|po|pot|csv|json|ini|dat|res|mo|qt)$";
      pass_filenames = false;
      entry = ''${symfonyCommand} console lint:translations'';
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };

    symfony-lint-xliff = {
      enable = true;
      name = "symfony lint:xliff";
      package = symfony-cli;
      files = "\.xlf$";
      entry = ''${symfonyCommand} console lint:xliff'';
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
      entry = ''${symfonyCommand} console lint:yaml'';
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
