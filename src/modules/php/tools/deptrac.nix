/**
  # Deptrac

  Deptrac is a static code analysis tool for PHP that helps you enforce
  architectural boundaries and prevent unwanted dependencies.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:deptrac`: 🔍 Analyze architecture with Deptrac.
  - `reset:php:tools:deptrac`: Delete 'deptrac/vendor' folder.
  - `cache:clear:php:deptrac`: Clear Deptrac cache.

  ### 👷 Commit hooks

  - `deptrac`: 🔍 Analyze architecture with Deptrac.

  ## 🛠️ Tech Stack

  - [Deptrac homepage](https://qossmic.github.io/deptrac/).
  - [Deptrac @ GitHub](https://github.com/qossmic/deptrac).

  ### 🧑‍💻 Visual Studio Code

  - [Deptrac @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=qossmic.deptrac-vscode).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
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
  cfg = phpToolsCfg.deptrac;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/deptrac/vendor/qossmic/deptrac/deptrac";
  toolConfiguration = {
    name = "Deptrac";
    namespace = "deptrac";
    composerJsonPath = ../../../files/php/tools/deptrac/composer.json;
    configFiles = {
      "deptrac.yaml" = ../../../files/php/deptrac.yaml;
    };
    ignoredPaths = [ "deptrac.yaml" ];
  };
in
{
  options.biapy-recipes.php.tools.deptrac = mkToolOptions phpToolsCfg "deptrac";

  config = mkIf cfg.enable {
    scripts = {
      deptrac = {
        description = "Deptrac";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "Deptrac is not installed."
            exit 1
          fi

          ${phpCommand} '${toolCommand}' "''${@}"
        '';
      };
    };

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "qossmic.deptrac-vscode" ];

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:lint:php:deptrac" = {
          description = "🔍 Analyze architecture with Deptrac";
          exec = ''
            cd "''${DEVENV_ROOT}"
            deptrac analyse --no-progress
          '';
        };

        "cache:clear:php:deptrac" = {
          description = "🗑️ Clear Deptrac cache";
          exec = ''
            cd "''${DEVENV_ROOT}"
            deptrac cache:clear
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      (mkPhpToolGoTasks toolConfiguration)
      // optionalAttrs cfg.go-task {
        "ci:lint:php:deptrac" = patchGoTask {
          aliases = [ "deptrac" ];
          desc = "🔍 Analyze architecture with Deptrac";
          cmds = [ "deptrac analyse --no-progress" ];
        };

        "cache:clear:php:deptrac" = patchGoTask {
          aliases = [
            "deptrac-cc"
            "deptrac:cc"
          ];
          desc = "🗑️ Clear Deptrac cache";
          cmds = [ "deptrac cache:clear" ];
        };
      };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      deptrac = {
        enable = mkDefault true;
        name = "Deptrac";
        inherit (config.languages.php) package;
        entry = "deptrac";
        args = [
          "analyse"
          "--no-progress"
        ];
      };
    };
  };
}
