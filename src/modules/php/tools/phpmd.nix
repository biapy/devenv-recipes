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
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkDefault mkIf;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (php-recipe-lib) mkPhpToolTasks mkPhpToolGoTasks;

  inherit (config.devenv) root;

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.phpmd;

  phpCommand = lib.meta.getExe config.languages.php.package;
  phpmdCommand = "${root}/${phpToolsCfg.path}/phpmd/vendor/bin/phpmd";
  pdependCommand = "${root}/${phpToolsCfg.path}/phpmd/vendor/bin/pdepend";

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
        description = mkDefault "PHP Mess Detector";
        exec = mkDefault ''
          if [[ ! -e '${phpmdCommand}' ]]; then
            echo "PHP Mess Detector is not installed."
            exit 1
          fi

          ${phpCommand} -d 'error_reporting=~E_DEPRECATED' '${phpmdCommand}' "''${@}"
        '';
      };

      pdepend = {
        description = mkDefault "PHP Depend";
        exec = mkDefault ''
          if [[ ! -e '${pdependCommand}' ]]; then
            echo "PHP Depend is not installed."
            exit 1
          fi

          ${phpCommand} -d 'error_reporting=~E_DEPRECATED' '${pdependCommand}' "''${@}"
        '';
      };
    };

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "ecodes.vscode-phpmd" ];

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:lint:php:phpmd" = {
          description = mkDefault "🔍 Lint 🐘PHP files with PHP Mess Detector";
          exec = mkDefault ''
            cd "''${DEVENV_ROOT}"
            phpmd analyze --ruleset='phpmd.xml' {src,tests}
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      optionalAttrs cfg.go-task {
        "ci:lint:php:phpmd" = mkDefault (patchGoTask {
          aliases = mkDefault [ "phpmd" ];
          desc = mkDefault "🔍 Lint 🐘PHP files with PHP Mess Detector";
          cmds = mkDefault [ "phpmd analyze --ruleset='phpmd.xml' {src,tests}" ];
        });
      }
      // mkPhpToolGoTasks toolConfiguration;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      phpmd = {
        enable = mkDefault true;
        name = mkDefault "PHP Mess Detector";
        inherit (config.languages.php) package;
        files = mkDefault "\\.php$";
        require_serial = mkDefault true;
        # Using bash to pipeline the filenames to phpmd stdin
        entry = mkDefault "phpmd analyze --no-progress --ruleset='${root}/phpmd.xml'";
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
