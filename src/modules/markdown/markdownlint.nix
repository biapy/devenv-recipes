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
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (lib.attrsets) optionalAttrs;

  mdCfg = config.biapy-recipes.markdown;
  cfg = mdCfg.markdownlint;

  markdownlint = config.git-hooks.hooks.markdownlint.package;
  markdownlintCommand = lib.meta.getExe markdownlint;

  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
in
{
  options.biapy-recipes.markdown.markdownlint = mkToolOptions mdCfg "markdownlint";

  config = mkIf cfg.enable {
    packages = [
      markdownlint
      fd
    ];

    devcontainer.settings.customizations.vscode.extensions = [ "DavidAnson.vscode-markdownlint" ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks { markdownlint.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:md:markdownlint" = mkDefault {
        description = "Lint *.md files with markdownlint";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.md$' "''${DEVENV_ROOT}" --exec-batch ${markdownlintCommand} {}
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:md:markdownlint" = mkDefault {
        aliases = [ "markdownlint" ];
        desc = "Lint *.md files with markdownlint";
        cmds = [ ''fd '\.md$' "''${DEVENV_ROOT}" --exec-batch markdownlint {}'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
