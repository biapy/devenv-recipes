/**
  # Twig CS Fixer

  Twig CS Fixer automatically fixes Twig Coding Standards issues.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:twig:twig-cs-fixer`: 🔍 Lint 🍃Twig with twig-cs-fixer.

  ## 🛠️ Tech Stack

  - [Twig CS Fixer homepage](https://twigcsfixer.github.io/).
  - [Twig CS Fixer @ GitHub](https://github.com/friendsoftwig/twig-cs-fixer).
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
  twigCfg = config.biapy-recipes.twig;
  cfg = twigCfg.tools.twig-cs-fixer;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/twig-cs-fixer/vendor/bin/twig-cs-fixer";
  toolConfiguration = {
    name = "twig-cs-fixer";
    namespace = "twig-cs-fixer";
    composerJsonPath = ../../../files/twig/tools/twig-cs-fixer/composer.json;
    configFiles = {
      ".twig-cs-fixer.dist.php" = ../../../files/twig/.twig-cs-fixer.dist.php;
    };
    ignoredPaths = [ ".twig-cs-fixer.cache" ];
  };
in
{
  options.biapy-recipes.twig.tools.twig-cs-fixer = mkToolOptions twigCfg "twig-cs-fixer";

  config = mkIf cfg.enable {
    languages.php.enable = true;

    scripts = {
      twig-cs-fixer = mkDefault {
        description = "twig-cs-fixer - Twig Code Sniffer";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "twig-cs-fixer is not installed."
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
        "ci:lint:twig:twig-cs-fixer" = mkDefault {
          description = "🔍 Lint 🍃Twig with twig-cs-fixer";
          exec = ''
            cd "''${DEVENV_ROOT}"
            twig-cs-fixer lint
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:twig:twig-cs-fixer" = mkDefault (patchGoTask {
          aliases = [ "twig-cs-fixer" ];
          desc = "🔍 Lint 🍃Twig with twig-cs-fixer";
          cmds = [ "twig-cs-fixer lint" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # See full reference at https://devenv.sh/reference/options/
  };
}
