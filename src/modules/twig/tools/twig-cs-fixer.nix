/**
  # Twig CS Fixer

  Twig CS Fixer automatically fixes Twig Coding Standards issues.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:twig:twig-cs-fixer`: 🔍 Lint 🍃Twig with twig-cs-fixer.
  - `ci:format:twig:twig-cs-fixer`: 🎨 Format 🍃Twig files with twig-cs-fixer.

  ### 👷 Commit hooks

  - `twig-cs-fixer`: Lint '.twig' files with Twig CS Fixer.

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
            twig-cs-fixer 'lint' --no-interaction
          '';
        };
        "ci:format:twig:twig-cs-fixer" = mkDefault {
          description = "🎨 Format 🍃Twig files with twig-cs-fixer";
          exec = ''
            cd "''${DEVENV_ROOT}"
            twig-cs-fixer 'fix' --no-interaction
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:twig:twig-cs-fixer" = mkDefault (patchGoTask {
          desc = "🔍 Lint 🍃Twig with twig-cs-fixer";
          cmds = [ "twig-cs-fixer 'lint' --no-interaction" ];
        });

        "ci:format:twig:twig-cs-fixer" = patchGoTask {
          aliases = [ "twig-cs-fixer" ];
          desc = "🎨 Format 🍃Twig files with twig-cs-fixer";
          cmds = [ "twig-cs-fixer 'fix' --no-interaction" ];
        };
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      twig-cs-fixer = mkDefault {
        enable = true;
        name = "Twig CS Fixer";
        inherit (config.languages.php) package;
        files = "\\.twig$";
        entry = "twig-cs-fixer 'lint'";
        args = [
          "--quiet"
          "--no-interaction"
        ];
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
