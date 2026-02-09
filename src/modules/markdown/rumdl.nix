/**
  # Rumdl

  `rumdl` is a Markdown linter written in Rust.
  It checks Markdown files for style issues and common mistakes.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:md:rumdl`: Lint `.md` files with `rumdl`.
  - `ci:format:md:rumdl`: Format `.md` files with `rumdl`.

  ### 👷 Commit hooks

  - `rumdl`: Lint `.md` files with `rumdl`.

  ## 🛠️ Tech Stack

  - [rumdl](https://rumdl.dev/)
    ([rumdl @ GitHub](https://github.com/rvben/rumdl)).

  ### 🧑‍💻 Visual Studio Code

  - [rumdl - Markdown Linter @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=rvben.rumdl).
*/
{
  pkgs,
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkBefore mkDefault mkIf;
  inherit (lib.options) mkOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  treefmtWrapper = config.git-hooks.hooks.treefmt.package;
  treefmtCommand = "${treefmtWrapper}/bin/treefmt";

  mdCfg = config.biapy-recipes.markdown;
  cfg = mdCfg.rumdl;

  rumdl = cfg.package;
  rumdlCommand = lib.meta.getExe rumdl;
in
{
  options.biapy-recipes.markdown.rumdl = mkToolOptions mdCfg "rumdl" // {
    package = mkOption {
      description = "The rumdl package to use.";
      defaultText = "pkgs.rumdl";
      type = lib.types.package;
      default = pkgs.rumdl;
    };
  };

  config = mkIf cfg.enable {
    devcontainer.settings.customizations.vscode.extensions = [ "rvben.rumdl" ];

    packages = [ rumdl ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      rumdl = {
        enable = mkDefault (!config.git-hooks.hooks.treefmt.enable);
        package = mkBefore cfg.package;
      };
    };

    treefmt.config.programs.rumdl-format = {
      enable = mkDefault true;
      package = mkBefore cfg.package;
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:md:rumdl" = {
        description = mkDefault "🔍 Lint 📝Markdown files with rumdl";
        exec = mkDefault ''
          cd "''${DEVENV_ROOT}"
          ${rumdlCommand} check
        '';
      };

      "ci:format:md:rumdl" = {
        description = mkDefault "🎨 Format 📝Markdown files with rumdl";
        exec = mkDefault ''
          cd "''${DEVENV_ROOT}"
            ${treefmtCommand} --formatters='rumdl-format'
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:md:rumdl" = patchGoTask {
        aliases = mkDefault [
          "lint:md:rumdl"
          "lint:rumdl"
        ];
        desc = mkDefault "🔍 Lint 📝Markdown files with rumdl";
        cmds = mkDefault [ "rumdl check" ];
      };

      "ci:format:md:rumdl" = patchGoTask {
        aliases = mkDefault [
          "rumdl"
          "format:md:rumdl"
          "format:rumdl"
        ];
        desc = mkDefault "🎨 Format 📝Markdown files with rumdl";
        cmds = mkDefault [ "treefmt --formatters='rumdl-format'" ];
      };
    };
  };
}
