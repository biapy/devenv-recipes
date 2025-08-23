/**
  # Symfony

  Symfony is a powerful PHP framework that empowers developers to build
  scalable, high-performance web applications with reusable components,
  comprehensive documentation, and a strong community.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:symfony:container`: Lint services container with Symfony console.
  - `ci:lint:symfony:translations`: Lint translations with Symfony console.
  - `ci:lint:symfony:twig`: Lint 'twig' files with Symfony console.
  - `ci:lint:symfony:xliff`: Lint 'xlf' files with Symfony console.
  - `ci:lint:symfony:yaml`: Lint 'yml' files with Symfony console.

  ### 👷 Commit hooks

  - `symfony-lint-container`: Lint services container with Symfony console.
  - `symfony-lint-twig`: Lint 'twig' files with Symfony console.
  - `symfony-lint-translations`: Lint translations with Symfony console.
  - `symfony-lint-xliff`: Lint 'xlf' files with Symfony console.
  - `symfony-lint-yaml`: Lint 'yml' files with Symfony console.

  ### 🐚 Commands

  - `composer-recipes-install-all`: Install or reinstall all Composer recipes.

  ## 🛠️ Tech Stack

  - [Symfony homepage](https://symfony.com/).
  - [fd @ GitHub](https://github.com/sharkdp/fd).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [lib.strings.isString @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.isString).
  - [builtins.readFile @ Nix 2.28.5 Reference Manual](https://nix.dev/manual/nix/2.28/language/builtins.html#builtins-readFile).
  - [Operators @ Nix 2.28.5 Reference Manual](https://nix.dev/manual/nix/2.28/language/operators.html).
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
    export PATH="${root}/bin:$PATH"
  '';

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:symfony:container" = {
      description = "Lint services container with Symfony console";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${symfonyCommand} console 'lint:container'
      '';
    };

    "ci:lint:symfony:translations" = {
      description = "Lint translations with Symfony console";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${symfonyCommand} console 'lint:translations'
      '';
    };

    "ci:lint:symfony:twig" = {
      description = "Lint 'twig' files with Symfony console";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${fdCommand} --extension='twig' --type='file' --exec-batch \
            ${symfonyCommand} console 'lint:twig' '--show-deprecations'
      '';
    };

    "ci:lint:symfony:xliff" = {
      description = "Lint 'xlf' files with Symfony console";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${fdCommand} --extension='xlf' --type='file' --exec-batch \
          ${symfonyCommand} console 'lint:xliff'
      '';
    };

    "ci:lint:symfony:yaml" = {
      description = "Lint 'yml' files with Symfony console";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${fdCommand} --extension='yml' --extension='yaml' --type='file' --exec-batch \
            ${symfonyCommand} console 'lint:yaml'
      '';
    };
  }
  // utils.tasks.gitIgnoreTask {
    name = "Symfony";
    namespace = "symfony";
    ignoredPaths = [ "composer-recipes-install-all" ];
  };

  files."bin/composer-recipes-install-all" = {
    executable = true;
    text = builtins.readFile ../files/php/bin/composer-recipes-install-all.bash;
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
    };

    symfony-lint-translations = {
      enable = true;
      name = "symfony lint:translations";
      package = symfony-cli;
      files = "/translations/.*\.(php|xlf|yml|yaml|po|pot|csv|json|ini|dat|res|mo|qt)$";
      pass_filenames = false;
      entry = ''${symfonyCommand} console lint:translations'';
    };

    symfony-lint-xliff = {
      enable = true;
      name = "symfony lint:xliff";
      package = symfony-cli;
      files = "\.xlf$";
      entry = ''${symfonyCommand} console lint:xliff'';
    };

    symfony-lint-yaml = {
      enable = true;
      name = "symfony lint:yaml";
      package = symfony-cli;
      files = "\.(yml|yaml)$";
      entry = ''${symfonyCommand} console lint:yaml'';
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
