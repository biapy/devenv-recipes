/**
  # Symfony

  Symfony is a powerful PHP framework that empowers developers to build
  scalable, high-performance web applications with reusable components,
  comprehensive documentation, and a strong community.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:symfony:container`: Lint services container with Symfony console.
  - `ci:lint:php:symfony:translations`: Lint translations with Symfony console.
  - `ci:lint:php:symfony:twig`: Lint 'twig' files with Symfony console.
  - `ci:lint:php:symfony:xliff`: Lint 'xlf' files with Symfony console.
  - `ci:lint:php:symfony:yaml`: Lint 'yml' files with Symfony console.
  - `cache:clear:php:symfony`: Clear all Symfony caches.
  - `cache:clear:php:symfony:var`: Clear Symfony var/cache directory.
  - `cache:clear:php:symfony:pool`: Clear Symfony cache pools.

  #### Doctrine ORM Tasks (when `doctrine.enable = true`)

  - `dev:db:migrate:symfony`: Run Doctrine migrations.
  - `dev:db:diff:symfony`: Generate Doctrine migration from diff.
  - `ci:lint:php:symfony:doctrine:validate`: Validate Doctrine mapping.

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
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.options) mkPackageOption;
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.tasks) mkGitIgnoreTask;
  inherit (recipes-lib.go-tasks) patchGoTask;

  phpCfg = config.biapy-recipes.php;
  cfg = phpCfg.symfony;

  php = config.languages.php.package;

  inherit (config.devenv) root;
  symfony-cli = cfg.package;
  symfonyCommand = lib.meta.getExe symfony-cli;
  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
in
{
  options.biapy-recipes.php.symfony = mkToolOptions { enable = false; } "symfony" // {
    package = mkPackageOption pkgs "symfony-cli" { };

    doctrine = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Doctrine ORM tasks";
      };
    };
  };

  config = mkIf cfg.enable {
    packages = [ fd ];

    biapy-recipes.php.ini.short_open_tag = "off";

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

    enterTest = ''
      symfony 'version' | command grep --color='auto' "${symfony-cli.version}"
      ${symfonyCommand} 'local:php:list' | command grep --color='auto' "${php}"
      ${symfonyCommand} 'local:check:requirements'
    '';

    # https://devenv.sh/tasks/
    tasks = {
      "biapy-recipes:enterShell:initialize:php:symfony" = {
        description = ''Detect devenv PHP version for 🎶Symfony CLI'';
        before = [ "devenv:enterShell" ];
        status = ''${symfonyCommand} 'local:php:list' | command grep --quiet "${php}"'';
        exec = ''
          ${symfonyCommand} 'local:php:refresh'
        '';
      };
    }
    // optionalAttrs cfg.tasks {
      "ci:secops:php:symfony" = {
        description = "🕵️‍♂️ Audit 🎶Symfony project packages";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${symfonyCommand} console 'local:check:security'
        '';
      };

      "ci:lint:php:symfony:container" = {
        description = "🔍 Lint 🎶Symfony services container";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${symfonyCommand} console 'lint:container'
        '';
      };

      "ci:lint:php:symfony:translations" = {
        description = "🔍 Lint 🎶Symfony translations";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${symfonyCommand} console 'lint:translations'
        '';
      };

      "ci:lint:php:symfony:twig" = {
        description = "🔍 Lint 🎶Symfony 'twig' files";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} --extension='twig' --type='file' --exec-batch \
              ${symfonyCommand} console 'lint:twig' '--show-deprecations'
        '';
      };

      "ci:lint:php:symfony:xliff" = {
        description = "🔍 Lint 🎶Symfony 'xlf' files";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} --extension='xlf' --type='file' --exec-batch \
            ${symfonyCommand} console 'lint:xliff'
        '';
      };

      "ci:lint:php:symfony:yaml" = {
        description = "🔍 Lint 🎶Symfony 'yml' files";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} --extension='yml' --extension='yaml' --type='file' --exec-batch \
              ${symfonyCommand} console 'lint:yaml'
        '';
      };

      "cache:clear:php:symfony:var" = {
        description = "🗑️ Clear 🎶Symfony var/cache directory";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${symfonyCommand} console 'cache:clear'

        '';
      };

      "cache:clear:php:symfony:pool" = {
        description = "🗑️ Clear 🎶Symfony cache pools";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${symfonyCommand} console 'cache:pool:clear' --all
        '';
      };
    }
    // optionalAttrs (cfg.tasks && cfg.doctrine.enable) {
      "dev:db:migrate:symfony" = {
        description = "🗃️ Run 🎶Symfony Doctrine migrations";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${symfonyCommand} console 'doctrine:migrations:migrate' --no-interaction
        '';
      };

      "dev:db:diff:symfony" = {
        description = "🗃️ Generate 🎶Symfony Doctrine migration from diff";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${symfonyCommand} console 'doctrine:migrations:diff'
        '';
      };

      "ci:lint:php:symfony:doctrine:validate" = {
        description = "🔍 Validate 🎶Symfony Doctrine mapping";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${symfonyCommand} console 'doctrine:schema:validate'
        '';
      };
    }
    // mkGitIgnoreTask {
      name = "Symfony";
      namespace = "php:symfony";
      ignoredPaths = [ "composer-recipes-install-all" ];
    };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:secops:php:symfony" = patchGoTask {
          desc = "🕵️‍♂️ Audit 🎶Symfony project packages";
          cmds = [ "symfony 'local:check:security'" ];
        };

        "ci:lint:php:symfony:container" = patchGoTask {
          desc = "🔍 Lint 🎶Symfony services container";
          cmds = [ "symfony console 'lint:container'" ];
        };

        "ci:lint:php:symfony:translations" = patchGoTask {
          desc = "🔍 Lint 🎶Symfony translations";
          cmds = [ "symfony console 'lint:translations'" ];
        };

        "ci:lint:php:symfony:twig" = patchGoTask {
          desc = "🔍 Lint 🎶Symfony 'twig' files";
          cmds = [
            "fd --extension='twig' --type='file' --exec-batch symfony console 'lint:twig' --show-deprecations"
          ];
          requires.vars = [ "DEVENV_ROOT" ];
        };

        "ci:lint:php:symfony:xliff" = patchGoTask {
          desc = "🔍 Lint 🎶Symfony 'xlf' files";
          cmds = [ "fd --extension='xlf' --type='file' --exec-batch symfony console 'lint:xliff'" ];
        };

        "ci:lint:php:symfony:yaml" = patchGoTask {
          desc = "🔍 Lint 🎶Symfony 'yml' files";
          cmds = [
            "fd --extension='yml' --extension='yaml' --type='file' --exec-batch symfony console 'lint:yaml'"
          ];
        };

        "cache:clear:php:symfony" = {
          desc = "🗑️ Run all 🎶Symfony cache clearing tasks";
        };

        "cache:clear:php:symfony:var" = patchGoTask {
          desc = "🗑️ Clear 🎶Symfony var/cache directory";
          cmds = [ "symfony console 'cache:clear'" ];
        };

        "cache:clear:php:symfony:pool" = patchGoTask {
          desc = "🗑️ Clear 🎶Symfony cache pools";
          cmds = [ "symfony console 'cache:pool:clear' --all" ];
        };
      }
      // optionalAttrs (cfg.go-task && cfg.doctrine.enable) {
        "dev:db:migrate:symfony" = patchGoTask {
          aliases = [ "doctrine-migrate" ];
          desc = "🗃️ Run 🎶Symfony Doctrine migrations";
          cmds = [ "symfony console 'doctrine:migrations:migrate' --no-interaction" ];
        };

        "dev:db:diff:symfony" = patchGoTask {
          aliases = [ "doctrine-diff" ];
          desc = "🗃️ Generate 🎶Symfony Doctrine migration from diff";
          cmds = [ "symfony console 'doctrine:migrations:diff'" ];
        };

        "ci:lint:php:symfony:doctrine" = patchGoTask {
          aliases = [ "doctrine-validate" ];
          desc = "🔍 Validate 🎶Symfony Doctrine mapping";
          cmds = [ "symfony console 'doctrine:schema:validate'" ];
        };
      };

    files."bin/composer-recipes-install-all" = {
      executable = true;
      text = builtins.readFile ../../files/php/bin/composer-recipes-install-all.bash;
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      symfony-check-security = {
        enable = mkDefault true;
        name = "symfony check:security";
        package = symfony-cli;
        pass_filenames = false;
        entry = ''${symfonyCommand} console local:check:security'';
        stages = [ "pre-push" ];
      };

      symfony-lint-container = {
        enable = mkDefault true;
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
        enable = mkDefault true;
        name = "symfony lint:twig";
        package = symfony-cli;
        files = "\.twig$";
        entry = ''${symfonyCommand} console lint:twig'';
        args = [ "--show-deprecations" ];
      };

      symfony-lint-translations = {
        enable = mkDefault true;
        name = "symfony lint:translations";
        package = symfony-cli;
        files = "/translations/.*\.(php|xlf|yml|yaml|po|pot|csv|json|ini|dat|res|mo|qt)$";
        pass_filenames = false;
        entry = ''${symfonyCommand} console lint:translations'';
      };

      symfony-lint-xliff = {
        enable = mkDefault true;
        name = "symfony lint:xliff";
        package = symfony-cli;
        files = "\.xlf$";
        entry = ''${symfonyCommand} console lint:xliff'';
      };

      symfony-lint-yaml = {
        enable = mkDefault true;
        name = "symfony lint:yaml";
        package = symfony-cli;
        files = "\.(yml|yaml)$";
        entry = ''${symfonyCommand} console lint:yaml'';
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
