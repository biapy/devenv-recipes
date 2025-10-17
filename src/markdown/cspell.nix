/**
  # CSpell

  `cspell` is a Spell Checker for Code.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:md:cspell`: Lint `.md` files with `cspell`.

  ### 👷 Commit hooks

  - `cspell`: Lint `.md` files with `cspell`.

  ## 🛠️ Tech Stack

  - [CSpell homepage](https://cspell.org/)
    ([CSpell @ GitHub](https://github.com/streetsidesoftware/cspell)).

  ### 🧑‍💻 Visual Studio Code

  - [Code Spell Checker @ Visual Studio Code Marketplace](hhttps://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker).

  ## 🙇 Acknowledgements

  - [git-hooks.hooks.cspell @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshookscspell).
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
  cfg = mdCfg.cspell;

  cspell = config.git-hooks.hooks.cspell.package;
  cspellCommand = "${cspell}/bin/cspell";
in
{
  options.biapy.markdown.cspell = {
    enable = mkOption {
      type = types.bool;
      description = "Enable cspell integration";
      default = mdCfg.enable;
    };

    git-hooks = mkOption {
      type = types.bool;
      description = "Enable cspell git hooks";
      default = true;
    };

    tasks = mkOption {
      type = types.bool;
      description = "Enable cspell devenv tasks";
      default = true;
    };

    go-task = mkOption {
      type = types.bool;
      description = "Enable cspell Taskfile tasks";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    devcontainer.settings.customizations.vscode.extensions = [
      "streetsidesoftware.code-spell-checker"
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks {
      cspell = {
        enable = true;
        files = ".*\.md$";
      };
    };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:lint:md:cspell" = {
        description = "Lint *.md files with cspell";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${cspellCommand} --root "''${DEVENV_ROOT}" "./**/*.md"
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:md:cspell" = mkDefault {
        aliases = [ "cspell" ];
        desc = "Lint *.md files with cspell";
        cmds = [ ''${cspellCommand} --root "''${DEVENV_ROOT}" "./**/*.md"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
        shopt = [ "globstar" ];
      };
    };
  };
}
