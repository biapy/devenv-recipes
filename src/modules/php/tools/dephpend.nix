/**
  # dePHPend

  `dephpend` is a dependency analyzer for PHP that helps you visualize and analyze dependencies in your code.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:dephpend`: 🔍 Analyze PHP dependencies with dePHPend.
  - `reset:php:tools:dephpend`: Delete 'dephpend/vendor' folder.

  ### 👷 Commit hooks

  - `dephpend`: 🔍 Analyze PHP dependencies with dePHPend.

  ## 🛠️ Tech Stack

  - [dePHPend @ GitHub](https://github.com/mihaeu/dephpend).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  config,
  lib,
  pkgs,
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
  cfg = phpToolsCfg.dephpend;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/dephpend/vendor/bin/dephpend";
  toolConfiguration = {
    name = "dePHPend";
    namespace = "dephpend";
    composerJsonPath = ../../../files/php/tools/dephpend/composer.json;
  };
in
{
  options.biapy-recipes.php.tools.dephpend = mkToolOptions { enable = false; } "dephpend";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ pkgs.graphviz ];

    scripts = {
      dephpend = mkDefault {
        description = "dePHPend - PHP dependency analyzer";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "dePHPend is not installed."
            exit 1
          fi

          ${phpCommand} '${toolCommand}' "''${@}"
        '';
      };
    };

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:lint:php:dephpend" = mkDefault {
          description = "🔍 Analyze PHP dependencies with dePHPend";
          exec = ''
            cd "''${DEVENV_ROOT}"
            dephpend text src
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:dephpend" = mkDefault (patchGoTask {
          aliases = [ "dephpend" ];
          desc = "🔍 Analyze PHP dependencies with dePHPend";
          cmds = [ "dephpend text src" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      dephpend = mkDefault {
        enable = false;
        name = "dePHPend";
        inherit (config.languages.php) package;
        entry = "dephpend";
        args = [
          "text"
          "src"
        ];
        pass_filenames = false;
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
