/**
  # Mdformat

  `mdformat` is an opinionated Markdown formatter that can be used to enforce
  a consistent style in Markdown files.
  Mdformat is a UNIX-style command-line tool as well as a Python library.

  ## 🛠️ Tech Stack

  - [Mdformat homepage](https://mdformat.readthedocs.io/en/stable/)
    ([Mdformat @ GitHub](https://github.com/hukkin/mdformat)).

  ### Mdformat plugins

  - [mdformat-admon @ GitHub](https://github.com/KyleKing/mdformat-admon).
  - [mdformat-beautysh @ GitHub](https://github.com/hukkin/mdformat-beautysh).
  - [mdformat-footnote @ GitHub](https://github.com/executablebooks/mdformat-footnote).
  - [mdformat-frontmatter @ GitHub](https://github.com/butler54/mdformat-frontmatter).
  - [mdformat-gfm @ GitHub](https://github.com/hukkin/mdformat-gfm).
  - [mdformat-gfm-alerts @ GitHub](https://github.com/KyleKing/mdformat-gfm-alerts).
  - [mdformat-mkdocs @ GitHub](https://github.com/KyleKing/mdformat-mkdocs).
  - [mdformat-myst @ GitHub](https://github.com/executablebooks/mdformat-myst).
  - [mdformat-nix-alejandra @ GitHub](https://github.com/aldoborrero/mdformat-nix-alejandra).
  - [mdformat-simple-breaks @ GitHub](https://github.com/csala/mdformat-simple-breaks).
  - [mdformat-tables @ GitHub](https://github.com/hukkin/mdformat-tables).
  - [mdformat-toc @ GitHub](https://github.com/hukkin/mdformat-toc).
  - [mdformat-wikilink @ GitHub](https://github.com/tmr232/mdformat-wikilink).

  ### Third party tools

  - [Beautysh @ GitHub](https://github.com/lovesegfault/beautysh).
  - [Alejandra 💅 homepage](https://kamadorueda.com/alejandra/)

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  pkgs,
  config,
  lib,
  ...
}:
let
  utils = import ../utils {
    inherit config;
    inherit lib;
  };
  pythonPackages = pkgs.python3Packages;
  mdformat = config.git-hooks.hooks.mdformat.package;
  mdformatCommand = lib.meta.getExe mdformat;
  mdformatInilializeFilesTask = utils.tasks.initializeFilesTask {
    name = "Mdformat";
    namespace = "mdformat";
    configFiles = {
      ".mdformat.toml" = ../files/markdown/.mdformat.toml;
    };
  };
in
{
  # https://devenv.sh/git-hooks/
  git-hooks.hooks.mdformat = {
    enable = true;
    package = pythonPackages.mdformat;
    extraPackages = with pythonPackages; [
      mdformat-admon
      mdformat-beautysh
      mdformat-footnote
      mdformat-frontmatter
      mdformat-gfm
      mdformat-gfm-alerts
      mdformat-mkdocs
      mdformat-myst
      mdformat-nix-alejandra
      mdformat-simple-breaks
      mdformat-tables
      # mdformat-toc # marked as broken on 2025-08-19
      mdformat-wikilink
    ];
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:format:md:mdformat" = {
      description = "Format *.md files with Mdformat";
      exec = ''
        set -o 'errexit'
        cd "''${DEVENV_ROOT}"
        ${mdformatCommand} ./
      '';
    };
  }
  // mdformatInilializeFilesTask;

}
