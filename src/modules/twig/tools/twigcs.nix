/**
  # twigcs

  `twigcs` aims to be what phpcs is to php.
  It checks your codebase for violations on coding standards.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:twig:twigcs`: 🔍 Lint 🍃Twig with twigcs.

  ## 🛠️ Tech Stack

  - [twigcs @ GitHub](https://github.com/friendsoftwig/twigcs).
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
  cfg = twigCfg.tools.twigcs;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/twigcs/vendor/bin/twigcs";
  toolConfiguration = {
    name = "twigcs";
    namespace = "twigcs";
    composerJsonPath = ../../../files/twig/tools/twigcs/composer.json;
    configFiles = {
      ".twig_cs.dist.php" = ../../../files/twig/.twig_cs.dist.php;
    };
  };
in
{
  options.biapy-recipes.twig.tools.twigcs = mkToolOptions twigCfg "twigcs";

  config = mkIf cfg.enable {
    languages.php.enable = true;

    scripts = {
      twigcs = mkDefault {
        description = "twigcs - Twig Code Sniffer";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "twigcs is not installed."
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
        "ci:lint:twig:twigcs" = mkDefault {
          description = "🔍 Lint 🍃Twig with twigcs";
          exec = ''
            cd "''${DEVENV_ROOT}"
            twigcs
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:twig:twigcs" = mkDefault (patchGoTask {
          aliases = [ "twigcs" ];
          desc = "🔍 Lint 🍃Twig with twigcs";
          cmds = [ "twigcs" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # See full reference at https://devenv.sh/reference/options/
  };
}
