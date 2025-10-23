/**
  # Rector

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:rector`: Lint '.php' files with Rector.
  - `ci:format:php:rector`: Apply Rector recommendations.
  - `reset:php:tools:rector`: Delete 'rector/vendor' folder.

  ### 👷 Commit hooks

  - `rector`: Lint '.php' files with Rector.

  ## 🛠️ Tech Stack

  - [Rector homepage](https://getrector.com/)
    ([Rector @ GitHub](https://github.com/rectorphp/rector)).

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
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (php-recipe-lib) mkPhpToolTasks mkPhpToolGoTasks;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.attrsets) optionalAttrs;

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.rector;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/rector/vendor/rector/rector/bin/rector";
  toolConfiguration = {
    name = "Rector";
    namespace = "rector";
    composerJsonPath = ../../../files/php/tools/rector/composer.json;
    configFiles = {
      "rector.php" = ../../../files/php/rector.php;
    };
  };
in
{
  options.biapy-recipes.php.tools.rector = mkToolOptions phpToolsCfg "rector";

  config = mkIf cfg.enable {
    scripts = {
      rector = {
        description = "Rector";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "Rector is not installed."
            exit 1
          fi

          ${phpCommand} '${toolCommand}' "''${@}"
        '';
      };
    };

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // lib.attrsets.optionalAttrs cfg.tasks {
        "ci:fix:php:rector" = {
          description = "🧹 Fix 🐘PHP files with Rector";
          before = [ "ci:format:php:php-cs-fixer" ];
          exec = ''
            cd "''${DEVENV_ROOT}"
            rector 'process' '--no-progress-bar'
          '';
        };

        "ci:lint:php:rector" = {
          description = "🔍 Lint 🐘PHP files with Rector";
          exec = ''
            cd "''${DEVENV_ROOT}"
            rector 'process' '--no-progress-bar' '--dry-run'
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      (mkPhpToolGoTasks toolConfiguration)
      // optionalAttrs cfg.go-task {
        "ci:fix:php:rector" = {
          aliases = [ "rector" ];
          desc = "🧹 Fix 🐘PHP files with Rector";
          cmds = [ "rector 'process' '--no-progress-bar'" ];
          requires.vars = [ "DEVENV_ROOT" ];
        };

        "ci:lint:php:rector" = {
          desc = "🔍 Lint 🐘PHP files with Rector";
          cmds = [ "rector 'process' '--no-progress-bar' '--dry-run'" ];
          requires.vars = [ "DEVENV_ROOT" ];
        };
      };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      rector = {
        enable = mkDefault true;
        name = "Rector";
        inherit (config.languages.php) package;
        pass_filenames = false;
        entry = ''${phpCommand} '${toolCommand}' "process"'';
        args = [
          "--no-progress-bar"
          "--dry-run"
        ];
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
