/**
    # markdownlint

    `markdownlint` is a Node.js style checker and lint tool for
    Markdown/CommonMark files.
  \
    ## 🧐 Features

    ### 🔨 Tasks

    - `ci:lint:md:markdownlint`: Lint `.md` files with `markdownlint`.

    ### 👷 Commit hooks

    - `markdownlint`: Lint `.md` files with `markdownlint`.

    ## 🛠️ Tech Stack

    - [markdownlint @ GitHub](https://github.com/DavidAnson/markdownlint).

    ### 🧑‍💻 Visual Studio Code

    - [markdownlint @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint).

    ## 🙇 Acknowledgements

    - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
    - [git-hooks.hooks.markdownlint @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksmarkdownlint).
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

  mdCfg = config.biapy-recipes.markdown;
  cfg = mdCfg.markdownlint;

  markdownlint = cfg.package;
  markdownlintCommand = lib.meta.getExe markdownlint;

  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;

  initializeFilesTask = mkInitializeFilesTask {
    name = "markdownlint";
    namespace = "markdownlint";
    configFiles = {
      ".markdownlint.json" = ../../files/markdown/.markdownlint.json;
    };
  };
in
{
  options.biapy-recipes.markdown.markdownlint = mkToolOptions mdCfg "markdownlint" // {
    package = mkOption {
      description = "The markdownlint package to use.";
      defaultText = "pkgs.markdownlint";
      type = lib.types.package;
      default = config.git-hooks.hooks.markdownlint.package;
    };
  };

  config = mkIf cfg.enable {
    packages = [
      markdownlint
      fd
    ];

    devcontainer.settings.customizations.vscode.extensions = [ "DavidAnson.vscode-markdownlint" ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks { markdownlint.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks =
      initializeFilesTask
      // optionalAttrs cfg.tasks {
        "ci:lint:md:markdownlint" = mkDefault {
          description = "🔍 Lint 📝Markdown files with markdownlint";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${fdCommand} '\.md$' "''${DEVENV_ROOT}" --exec-batch ${markdownlintCommand} {}
          '';
        };
      };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:md:markdownlint" = patchGoTask {
        aliases = [ "markdownlint" ];
        desc = "🔍 Lint 📝Markdown files with markdownlint";
        cmds = [ "fd '\\.md$' --exec-batch markdownlint {}" ];
      };
    };
  };
}
