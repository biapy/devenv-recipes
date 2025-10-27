/**
  # ergebnis/composer-normalize

  `ergebnis/composer-normalize` provides a `composer` plugin for normalizing
  `composer.json`.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:format:php:composer:normalize`: Reorganize `composer.json` files
    with `composer normalize`.
  - `reset:php:tools:composer-normalize`: Delete 'composer-normalize/vendor' folder.

  ### 👷 Commit hooks

  - `composer-normalize`: Reorganize `composer.json` files with
    `composer normalize`.

  ## 🛠️ Tech Stack

  - [ergebnis/composer-normalize @ GitHub](https://github.com/ergebnis/composer-normalize)

  ### 📦 Third party tools

  - [GNU Parallel homepage](https://www.gnu.org/software/parallel/).

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
  cfg = phpToolsCfg.composer-normalize;

  inherit (config.languages.php.packages) composer;
  composerCommand = lib.meta.getExe composer;

  parallel = config.biapy-recipes.gnu-parallel.package;
  parallelCommand = lib.meta.getExe parallel;

  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;

  toolConfiguration = {
    name = "composer normalize";
    namespace = "composer-normalize";
    composerJsonPath = ../../../files/php/tools/composer-normalize/composer.json;
  };
in
{
  options.biapy-recipes.php.tools.composer-normalize = mkToolOptions phpToolsCfg "composer-normalize";

  config = mkIf cfg.enable {
    scripts = {
      composer-normalize =
        let
          toolPath = "\${DEVENV_ROOT}/${phpToolsCfg.path}/${toolConfiguration.namespace}";
        in
        {
          description = "Composer Normalize";
          exec = ''
            if [[ ! -d "${toolPath}/vendor" ]]; then
              echo "Composer Normalize is not installed."
              exit 1
            fi

            absolute-path() {
              local inputPath="''${1}"

              if [[ -e "''${inputPath}" && ! "''${inputPath}" =~ ^/ ]]; then
                # If it's a file and not already an absolute path, rewrite it
                echo "$(cd "$(dirname "''${inputPath}")" && pwd)/$(basename "''${inputPath}")"

                return 0
              fi

              # Otherwise, leave as-is
              echo "''${inputPath}"

              return 0
            }

            composer-normalize() {
              local args=()

              for arg in "''${@}"; do
                args+=("$(absolute-path "''${arg}")")
              done

              ${composerCommand} --working-dir="${toolPath}" normalize "''${args[@]}"
            }

            composer-normalize "''${@}"
          '';
        };
    };

    biapy-recipes.gnu-parallel.enable = mkDefault true;

    # https://devenv.sh/packages/
    packages = [ fd ];

    # https://devenv.sh/tasks/
    tasks =
      (mkPhpToolTasks toolConfiguration)
      // optionalAttrs cfg.tasks {
        "ci:format:php:composer:normalize" = {
          description = "🎨 Format 🐘composer.json files with composer normalize";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${fdCommand} '^composer\.json$' "''${DEVENV_ROOT}" --exec \
              composer-normalize {}
          '';
        };
      };

    biapy.go-task.taskfile.tasks =
      (mkPhpToolGoTasks toolConfiguration)
      // optionalAttrs cfg.go-task {
        "ci:format:php:composer:normalize" = patchGoTask {
          aliases = [ "composer-normalize" ];
          desc = "🎨 Format 🐘composer.json files with composer normalize";
          cmds = [ "fd '^composer\\.json$' --exec composer-normalize {}" ];
        };
      };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      composer-normalize = {
        enable = mkDefault true;
        name = "composer normalize";
        before = [ "composer-validate" ];
        package = composer;
        extraPackages = [ parallel ];
        files = "composer.json";
        entry = ''"${parallelCommand}" composer-normalize --dry-run {} ::: '';
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
