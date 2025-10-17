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
{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkDefault
    mkOption
    types
    ;

  mdCfg = config.biapy.markdown;
  cfg = mdCfg.markdownlint;

  markdownlint = config.git-hooks.hooks.markdownlint.package;
  markdownlintCommand = lib.meta.getExe markdownlint;
in
{
  options.biapy.markdown.markdownlint = {
    enable = mkOption {
      type = types.bool;
      description = "Enable markdownlint integration";
      default = mdCfg.enable;
    };

    git-hooks = mkOption {
      type = types.bool;
      description = "Enable markdownlint git hooks";
      default = true;
    };

    tasks = mkOption {
      type = types.bool;
      description = "Enable markdownlint devenv tasks";
      default = true;
    };

    go-task = mkOption {
      type = types.bool;
      description = "Enable markdownlint Taskfile tasks";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    devcontainer.settings.customizations.vscode.extensions = [ "DavidAnson.vscode-markdownlint" ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks { markdownlint.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:lint:md:markdownlint" = mkDefault {
        description = "Lint *.md files with markdownlint";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${markdownlintCommand} "./**/*.md"
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:md:markdownlint" = mkDefault {
        aliases = [ "markdownlint" ];
        desc = "Lint *.md files with markdownlint";
        cmds = [ ''${markdownlintCommand} "./**/*.md"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
        shopt = [ "globstar" ];
      };
    };
  };
}
