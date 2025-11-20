/**
  # TOML

  TOML formatting and linting tools.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:config:toml`: Lint TOML files with `taplo`.
  - `ci:format:config:toml`: Format TOML files with `taplo`.

  ### 👷 Commit hooks

  - `taplo`: Format TOML files with `taplo`.

  ## 🛠️ Tech Stack

  - [taplo @ GitHub](https://github.com/tamasfe/taplo) - Rust-based TOML toolkit.

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.tasks) mkInitializeFilesTask;

  configCfg = config.biapy-recipes.config;
  cfg = configCfg.toml;

  inherit (cfg.packages) taplo;

  taploCommand = lib.meta.getExe taplo;

  taploInitializeFilesTask = mkInitializeFilesTask {
    name = "taplo";
    namespace = "taplo";
    configFiles = {
      ".taplo.toml" = ../../files/config/.taplo.toml;
    };
  };
in
{
  options.biapy-recipes.config.toml = mkToolOptions configCfg "toml" // {
    packages = {
      taplo = mkOption {
        description = "The taplo package to use.";
        defaultText = "pkgs.taplo";
        type = lib.types.package;
        default = pkgs.taplo;
      };
    };
  };

  config = mkIf cfg.enable {
    packages = [ taplo ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      taplo = {
        enable = mkDefault true;
        package = taplo;
      };
    };

    # https://devenv.sh/tasks/
    tasks =
      taploInitializeFilesTask
      // optionalAttrs cfg.tasks {
        "ci:lint:config:toml" = mkDefault {
          description = "🔍 Lint 🔧TOML files with taplo";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${taploCommand} 'lint'
          '';
        };
        "ci:format:config:toml" = mkDefault {
          description = "🎨 Format 🔧TOML files with taplo";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${taploCommand} 'format'
          '';
        };
      };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:config:toml" = mkDefault (patchGoTask {
        desc = "🔍 Lint 🔧TOML files with taplo";
        cmds = [ "taplo 'lint'" ];
      });

      "ci:format:config:toml" = mkDefault (patchGoTask {
        aliases = [ "taplo" ];
        desc = "🎨 Format 🔧TOML files with taplo";
        cmds = [ "taplo 'format'" ];
      });
    };
  };
}
