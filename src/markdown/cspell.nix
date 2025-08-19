/**
  # CSpell

  `cspell` is a Spell Checker for Code.

  ## 🛠️ Tech Stack

  - [CSpell homepage](https://cspell.org/)
    ([CSpell @ GitHub](https://github.com/streetsidesoftware/cspell)).
  - [Code Spell Checker @ Visual Studio Code Marketplace](hhttps://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker).
*/
_: {
  devcontainer.settings.customizations.vscode = {
    extensions = [ "streetsidesoftware.code-spell-checker" ];
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.cspell = {
    enable = true;
    files = ".*\.md$";
  };
}
