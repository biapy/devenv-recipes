/**
  # Psalm

  Psalm is a free & open-source static analysis tool that helps you identify
  problems in your code, so you can sleep a little better.
  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:psalm`: 🔍 Lint 🐘PHP files with Psalm.
  - `reset:php:tools:psalm`: Delete 'psalm/vendor' folder.
  - `cache:clear:php:psalm`: Clear Psalm cache.

  ### 👷 Commit hooks

  - `psalm`: 🔍 Lint 🐘PHP files with Psalm.

  ## 🛠️ Tech Stack

  - [Psalm homepage](https://psalm.dev/).
  - [Psalm @ GitHub](https://github.com/vimeo/psalm).

  ### 🧩 Psalm plugins

  - [phpunit-psalm-plugin @ GitHub](https://github.com/psalm/psalm-plugin-phpunit).
  - [Symfony Psalm Plugin @ GitHub](https://github.com/psalm/psalm-plugin-symfony).
  - [Doctrine Psalm Plugin @ GitHub](https://github.com/psalm/psalm-plugin-doctrine).

  ### 🧑‍💻 Visual Studio Code

  - [Psalm (PHP Static Analysis Linting Machine) @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=getpsalm.psalm-vscode-plugin).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.psalm @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshookspsalm).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{
  config,
  lib,
  php-recipe-lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (php-recipe-lib) mkPhpToolTasks mkPhpToolGoTasks;

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.psalm;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/psalm/vendor/vimeo/psalm/psalm";
  toolConfiguration = {
    name = "Psalm";
    namespace = "psalm";
    composerJsonPath = ../../../files/php/tools/psalm/composer.json;
    configFiles = {
      "psalm.xml.dist" = ../../../files/php/psalm.xml.dist;
    };
    ignoredPaths = [ "psalm.xml" ];
  };
in
{
  options.biapy-recipes.php.tools.psalm = mkToolOptions phpToolsCfg "psalm";

  config = mkIf cfg.enable {
    scripts = {
      psalm = {
        description = "Psalm";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "Psalm is not installed."
            exit 1
          fi

          ${phpCommand} '${toolCommand}' "''${@}"
        '';
      };
    };

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "getpsalm.psalm-vscode-plugin" ];

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:lint:php:psalm" = {
          description = "🔍 Lint 🐘PHP files with Psalm";
          exec = ''
            cd "''${DEVENV_ROOT}"
            psalm --no-progress --show-info --show-snippet
          '';
        };

        "cache:clear:php:psalm" = {
          description = "🗑️ Clear Psalm cache";
          exec = ''
            cd "''${DEVENV_ROOT}"
            psalm --clear-cache
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      (mkPhpToolGoTasks toolConfiguration)
      // optionalAttrs cfg.go-task {
        "ci:lint:php:psalm" = patchGoTask {
          aliases = [ "psalm" ];
          desc = "🔍 Lint 🐘PHP files with Psalm";
          cmds = [ "psalm --no-progress --show-info --show-snippet" ];
        };

        "cache:clear:php:psalm" = patchGoTask {
          aliases = [
            "cc:psalm"
            "cc-psalm"
            "psalm-cc"
            "psalm:cc"
          ];
          desc = "🗑️ Clear Psalm cache";
          cmds = [ "psalm --clear-cache" ];
        };
      };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      psalm = {
        enable = mkDefault true;
        name = "Psalm";
        inherit (config.languages.php) package;
        entry = "psalm";
        args = [ "--no-progress" ];
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
