/**
  # phpDocumentor

  `phpdoc` is the de-facto documentation application for PHP projects.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:docs:php:phpdoc`: 📚 Generate 🐘PHP files documentation with phpDocumentor.
  - `reset:php:tools:phpdoc`: Delete 'phpdoc/vendor' folder.

  ## 🛠️ Tech Stack

  - [phpDocumentor homepage](https://phpdoc.org/).
  - [phpDocumentor @ GitHub](https://github.com/phpdocumentor/phpdocumentor).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.phpdoc @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphpdoc).
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
  inherit (lib.modules) mkIf;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (php-recipe-lib) mkPhpToolTasks mkPhpToolGoTasks;

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.phpdoc;

  inherit (config.devenv) root;
  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/phpdoc/vendor/bin/phpdoc";
  toolConfiguration = {
    name = "phpDocumentor";
    namespace = "phpdoc";
    composerJsonPath = ../../../files/php/tools/phpdoc/composer.json;
    configFiles = {
      "phpdoc.dist.xml" = ../../../files/php/phpdoc.dist.xml;
    };
    ignoredPaths = [ ".phpdoc/cache" ];
  };
in
{
  options.biapy-recipes.php.tools.phpdoc = mkToolOptions phpToolsCfg "phpdoc";

  config = mkIf cfg.enable {
    scripts = {
      phpdoc = {
        description = "phpDocumentor";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "phpDocumentor is not installed."
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
        "ci:docs:php:phpdoc" = {
          description = "📚 Generate 🐘PHP files documentation with phpDocumentor";
          exec = ''
            cd "''${DEVENV_ROOT}"
            phpdoc 'project:run'
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:docs:php:phpdoc" = patchGoTask {
          aliases = [ "phpdoc" ];
          desc = "📚 Generate 🐘PHP files documentation with phpDocumentor";
          cmds = [ "phpdoc 'project:run'" ];
        };
      }
      // mkPhpToolGoTasks toolConfiguration;

    # See full reference at https://devenv.sh/reference/options/
  };
}
