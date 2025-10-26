/**
  # Vale

  Vale is an open-source, command-line tool that brings editorial style guides
  to life.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:md:vale`: Lint Markdown files with `vale`.

  ### 👷 Commit hooks

  - `vale`: Lint Markdown files with `vale`.

  ## 🛠️ Tech Stack

  - [Vale homepage](https://vale.sh/)
    ([Vale @ GitHub](https://github.com/errata-ai/vale)).
  - [Vale language server (vale-ls) @ GitHub](https://github.com/errata-ai/vale-ls)

  ### 🧑‍💻 Visual Studio Code

  - [Vale VSCode @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ChrisChinchilla.vale-vscode).

  ## 🙇 Acknowledgements

  - [git-hooks.hooks.vale @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksvale).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (pkgs) vale-ls;

  mdCfg = config.biapy-recipes.markdown;
  cfg = mdCfg.vale;

  vale = cfg.package;
  valeCommand = lib.meta.getExe vale;
in
{
  options.biapy-recipes.markdown.vale = mkToolOptions { enable = false; } "vale" // {
    package = mkOption {
      description = "The vale package to use.";
      defaultText = "config.git-hooks.hooks.vale.package";
      type = types.package;
      default = config.git-hooks.hooks.vale.package;
    };
    lintTask = mkOption {
      type = types.bool;
      description = "Enable ci:lint:md:vale tasks (resource and time heavy)";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    packages = [
      vale
      vale-ls
    ];

    devcontainer.settings.customizations.vscode.extensions = [ "ChrisChinchilla.vale-vscode" ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      vale = {
        enable = mkDefault true;
        files = ".*\.md$";
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:md:vale" = mkIf cfg.lintTask {
        description = "🔍 Lint 📝Markdown files with vale";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${valeCommand} --glob='*\.md' "''${DEVENV_ROOT}"
        '';
      };

      "update:md:vale" = {
        description = "⬆️ Update 📝Vale external configuration sources.";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${valeCommand} 'sync'
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:md:vale" = mkIf cfg.lintTask (patchGoTask {
        aliases = [ "vale" ];
        desc = "🔍 Lint 📝Markdown files with vale";
        cmds = [ "vale --glob='*\.md' './'" ];
      });

      "update:md:vale" = patchGoTask {
        desc = "⬆️ Update 📝Vale external configuration sources.";
        cmds = [ "vale 'sync'" ];
      };
    };
  };
}
