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
{ config, ... }:
let
  cspell = config.git-hooks.hooks.cspell.package;
  cspellCommand = "${cspell}/bin/cspell";
in
{
  devcontainer.settings.customizations.vscode.extensions = [
    "streetsidesoftware.code-spell-checker"
  ];

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.cspell = {
    enable = true;
    files = ".*\.md$";
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:md:cspell" = {
      description = "Lint *.md files with cspell";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${cspellCommand} --root "''${DEVENV_ROOT}" "./**/*.md"
      '';
    };
  };
}
