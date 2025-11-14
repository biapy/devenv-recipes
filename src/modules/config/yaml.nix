/**
  # YAML

  YAML formatting and linting tools.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:yaml:yamllint`: Lint YAML files with `yamllint`.
  - `ci:format:yaml:yamlfmt`: Format YAML files with `yamlfmt`.

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

  configCfg = config.biapy-recipes.config;
  cfg = configCfg.yaml;

  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;

  inherit (cfg.packages) yamllint yamlfmt;

  yamllintCommand = lib.meta.getExe yamllint;
  yamlfmtCommand = lib.meta.getExe yamlfmt;
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
      fd
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      yamllint = {
        enable = mkDefault true;
        package = yamllint;
      };
      yamlfmt = {
        enable = mkDefault true;
        package = yamlfmt;
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:yaml:yamllint" = {
        description = "🔍 Lint 📄YAML files with yamllint";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.(yaml|yml)$' "''${DEVENV_ROOT}" --exec ${yamllintCommand} {}
        '';
      };
      "ci:format:yaml:yamlfmt" = {
        description = "🎨 Format 📄YAML files with yamlfmt";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.(yaml|yml)$' "''${DEVENV_ROOT}" --exec ${yamlfmtCommand} -w {}
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:yaml:yamllint" = patchGoTask {
        aliases = [ "yamllint" ];
        desc = "🔍 Lint 📄YAML files with yamllint";
        cmds = [ "fd '\.(yaml|yml)$' --exec yamllint {}" ];
      };

      "ci:format:yaml:yamlfmt" = patchGoTask {
        aliases = [ "yamlfmt" ];
        desc = "🎨 Format 📄YAML files with yamlfmt";
        cmds = [ "fd '\.(yaml|yml)$' --exec yamlfmt -w {}" ];
      };
    };
  };
}
