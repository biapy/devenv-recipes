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
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (lib.attrsets) optionalAttrs;

  mdCfg = config.biapy-recipes.markdown;
  cfg = mdCfg.cspell;

  cspell = config.git-hooks.hooks.cspell.package;
  cspellCommand = "${cspell}/bin/cspell";
in
{
  options.biapy-recipes.markdown.cspell = mkToolOptions mdCfg "CSpell";

  config = mkIf cfg.enable {
    devcontainer.settings.customizations.vscode.extensions = [
      "streetsidesoftware.code-spell-checker"
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      cspell = {
        enable = mkDefault true;
        files = ".*\.md$";
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:md:cspell" = {
        description = "🔍 Lint 📝Markdown files with cspell";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${cspellCommand} --root "''${DEVENV_ROOT}" ./**/*.md
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:md:cspell" = mkDefault {
        aliases = [ "cspell" ];
        desc = "🔍 Lint 📝Markdown files with cspell";
        cmds = [ ''cspell --root "''${DEVENV_ROOT}" ./**/*.md'' ];
        requires.vars = [ "DEVENV_ROOT" ];
        shopt = [ "globstar" ];
      };
    };
  };
}
