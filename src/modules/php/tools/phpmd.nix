/**
  # PHP Mess Detector

  `phpmd` takes a given PHP source code base and look for several potential
  problems within that source.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:php:phpmd`: Lint 'src' and 'tests' with PHP Mess Detector.
  - `reset:php:tools:phpmd`: Delete 'phpmd/vendor' folder.

  ### 👷 Commit hooks

  - `phpmd`: Lint 'src' and 'tests' with PHP Mess Detector.

  ## 🛠️ Tech Stack

  - [PHP Mess Detector homepage](https://phpmd.org/).
  - [PHP Mess Detector @ GitHub](https://github.com/phpmd/phpmd).

  ### 🧑‍💻 Visual Studio Code

  - [PHP Mess Detector @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ecodes.vscode-phpmd).

  ### 📦 Third party tools

  - [GNU Parallel homepage](https://www.gnu.org/software/parallel/).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
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
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (php-recipe-lib) mkPhpToolTasks mkVendorResetGoTask;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.attrsets) optionalAttrs;

  inherit (config.devenv) root;

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.phpmd;

  phpCommand = lib.meta.getExe config.languages.php.package;
  toolCommand = "${root}/${phpToolsCfg.path}/phpmd/vendor/phpmd/phpmd/src/bin/phpmd";

  parallel = config.biapy-recipes.gnu-parallel.package;
  parallelCommand = lib.meta.getExe parallel;

  toolConfiguration = {
    name = "PHP Mess Detector";
    namespace = "phpmd";
    composerJsonPath = ../../../files/php/tools/phpmd/composer.json;
    configFiles = {
      "phpmd.xml" = ../../../files/php/phpmd.xml;
    };
    ignoredPaths = [ "/.phpmd.result-cache.php" ];
  };
in
{
  options.biapy-recipes.php.tools.phpmd = mkToolOptions phpToolsCfg "phpmd";

  config = mkIf cfg.enable {
    scripts = {
      phpmd = {
        description = "PHP Mess Detector";
        exec = ''
          if [[ ! -e '${toolCommand}' ]]; then
            echo "PHP Mess Detector is not installed."
            exit 1
          fi

          ${phpCommand} -d 'error_reporting=~E_DEPRECATED' '${toolCommand}' "''${@}"
        '';
      };
    };

    biapy-recipes.gnu-parallel.enable = mkDefault true;

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "ecodes.vscode-phpmd" ];

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:lint:php:phpmd" = {
          description = "🔍 Lint 🐘PHP files with PHP Mess Detector";
          exec = ''
            cd "''${DEVENV_ROOT}"
            phpmd {src,tests} 'ansi' 'phpmd.xml'
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:phpmd" = {
          aliases = [ "phpmd" ];
          desc = "🔍 Lint 🐘PHP files with PHP Mess Detector";
          cmds = [ "phpmd {src,tests} 'ansi' 'phpmd.xml" ];
          requires.vars = [ "DEVENV_ROOT" ];
        };
      }
      // mkVendorResetGoTask toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      phpmd = {
        enable = mkDefault true;
        name = "PHP Mess Detector";
        inherit (config.languages.php) package;
        extraPackages = [ parallel ];
        # Using parallel allows to run phpmd on staged files only
        entry = ''${parallelCommand} phpmd {} 'ansi' '${root}/phpmd.xml' ::: '';
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
