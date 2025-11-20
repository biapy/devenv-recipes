/**
  # YAML

  YAML formatting and linting tools.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:config:yaml`: Lint YAML files with `yamllint`.
  - `ci:format:config:yaml`: Format YAML files with `yamlfmt`.

  ### 👷 Commit hooks

  - `yamllint`: Lint YAML files with `yamllint`.
  - `yamlfmt`: Format YAML files with `yamlfmt`.

  ## 🛠️ Tech Stack

  - [yamllint @ GitHub](https://github.com/adrienverge/yamllint) - Python-based YAML linter.
  - [yamlfmt @ GitHub](https://github.com/google/yamlfmt) - Go-based YAML formatter.

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
  cfg = configCfg.yaml;

  inherit (cfg.packages) yamllint yamlfmt;

  yamllintCommand = lib.meta.getExe yamllint;
  yamlfmtCommand = lib.meta.getExe yamlfmt;

  yamlfmtInitializeFilesTask = mkInitializeFilesTask {
    name = "yamlfmt";
    namespace = "yamlfmt";
    configFiles = {
      ".yamlfmt.yml" = ../../files/config/.yamlfmt.yml;
    };
  };

  yamllintInitializeFilesTask = mkInitializeFilesTask {
    name = "yamllint";
    namespace = "yamllint";
    configFiles = {
      ".yamllint.yml" = ../../files/config/.yamllint.yml;
    };
  };
in
{
  options.biapy-recipes.config.yaml = mkToolOptions configCfg "yaml" // {
    packages = {
      yamllint = mkOption {
        description = "The yamllint package to use.";
        defaultText = "pkgs.yamllint";
        type = lib.types.package;
        default = pkgs.yamllint;
      };
      yamlfmt = mkOption {
        description = "The yamlfmt package to use.";
        defaultText = "pkgs.yamlfmt";
        type = lib.types.package;
        default = pkgs.yamlfmt;
      };
    };
  };

  config = mkIf cfg.enable {
    packages = [
      yamllint
      yamlfmt
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      yamllint = {
        enable = mkDefault true;
        package = yamllint;
        args = [ "--strict" ];
      };
      yamlfmt = {
        enable = mkDefault true;
        package = yamlfmt;
      };
    };

    # https://devenv.sh/tasks/
    tasks =
      yamlfmtInitializeFilesTask
      // yamllintInitializeFilesTask
      // optionalAttrs cfg.tasks {
        "ci:lint:config:yaml:yamllint" = mkDefault {
          description = "🔍 Lint 🔧YAML files with yamllint";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${yamllintCommand} --strict "''${DEVENV_ROOT}"
          '';
        };

        "ci:lint:config:yaml:yamlfmt" = mkDefault {
          description = "🔍 Lint 🔧YAML files with yamlfmt";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${yamlfmtCommand} --quiet --lint "''${DEVENV_ROOT}"
          '';
        };

        "ci:format:config:yaml" = mkDefault {
          description = "🎨 Format 🔧YAML files with yamlfmt";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${yamlfmtCommand} --verbose "''${DEVENV_ROOT}"
          '';
        };
      };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:config:yaml:yamllint" = mkDefault (patchGoTask {
        aliases = [ "yamllint" ];
        desc = "🔍 Lint 🔧YAML files with yamllint";
        cmds = [ "yamllint --strict './'" ];
      });

      "ci:lint:config:yaml:yamlfmt" = mkDefault (patchGoTask {
        desc = "🔍 Lint 🔧YAML files with yamlfmt";
        cmds = [ "yamlfmt --quiet --lint './'" ];
      });

      "ci:format:config:yaml" = mkDefault (patchGoTask {
        aliases = [ "yamlfmt" ];
        desc = "🎨 Format 🔧YAML files with yamlfmt";
        cmds = [ "yamlfmt './'" ];
      });
    };
  };
}
