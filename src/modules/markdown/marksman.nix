/**
  # Marksman

  Marksman is a program that integrates with editors to assist in writing
  and maintaining Markdown documents.
  Using LSP protocol it provides completion, goto definition, find references,
  rename refactoring, diagnostics, and more.
  In addition to regular Markdown, it also supports wiki-link-style references
  that enable Zettelkasten-like note taking.

  ## 🛠️ Tech Stack

  - [Marksman @ GitHub](https://github.com/artempyanykh/marksman).

  ### 🧑‍💻 Visual Studio Code

  - [Marksman @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=arr.marksman)
    ([Marksman VSCode @ GitHub](https://github.com/artempyanykh/marksman-vscode)).

  ## 🙇 Acknowledgements

  - [git-hooks.hooks.cspell @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshookscspell).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkPackageOption;
  inherit (recipes-lib.modules) mkToolOptions;

  mdCfg = config.biapy-recipes.markdown;
  cfg = mdCfg.marksman;

  marksman = cfg.package;
in
{
  options.biapy-recipes.markdown.marksman = mkToolOptions mdCfg "Marksman" // {
    package = mkPackageOption pkgs "marksman" { };
  };

  config = mkIf cfg.enable {
    packages = [ marksman ];

    devcontainer.settings.customizations.vscode.extensions = [ "arr.marksman" ];
  };
}
