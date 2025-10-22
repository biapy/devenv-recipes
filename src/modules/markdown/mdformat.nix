/**
  # Mdformat

  `mdformat` is an opinionated Markdown formatter that can be used to enforce
  a consistent style in Markdown files.
  Mdformat is a UNIX-style command-line tool as well as a Python library.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:md:mdformat`: Lint `.md` files with `mdformat`.
  - `ci:format:md:mdformat`: Format `.md` files with `mdformat`.

  ### 👷 Commit hooks

  - `mdformat`: Lint `.md` files with `mdformat`.

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

  ### 📦 Third party tools

  - [Beautysh @ GitHub](https://github.com/lovesegfault/beautysh).
  - [Alejandra 💅 homepage](https://kamadorueda.com/alejandra/)

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.mdformat @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksmdformat).
*/
{
  pkgs,
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.tasks) mkInitializeFilesTask;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (lib.attrsets) optionalAttrs;

  mdCfg = config.biapy-recipes.markdown;
  cfg = mdCfg.mdformat;

  pythonPackages = pkgs.python3Packages;
  mdformat = config.git-hooks.hooks.mdformat.package;
  mdformatCommand = lib.meta.getExe mdformat;
  mdformatInilializeFilesTask = mkInitializeFilesTask {
    name = "Mdformat";
    namespace = "mdformat";
    configFiles = {
      ".mdformat.toml" = ../../files/markdown/.mdformat.toml;
    };
  };

  mdformatExtensions = with pythonPackages; [
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
in
{
  options.biapy-recipes.markdown.mdformat = mkToolOptions mdCfg "mdformat";

  config = mkIf cfg.enable {

    packages = [ mdformat ] ++ mdformatExtensions;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.go-task {
      mdformat = {
        enable = mkDefault true;
        args = [ "--check" ];
        package = pythonPackages.mdformat;
        extraPackages = mdformatExtensions;
      };
    };

    # https://devenv.sh/tasks/
    tasks =
      mdformatInilializeFilesTask
      // optionalAttrs cfg.tasks {
        "ci:lint:md:mdformat" = {
          description = "🔍 Lint 📝Markdown files with mdformat";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${mdformatCommand} --check "''${DEVENV_ROOT}"
          '';
        };

        "ci:format:md:mdformat" = {
          description = "🎨 Format 📝Markdown files with mdformat";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${mdformatCommand} "''${DEVENV_ROOT}"
          '';
        };
      };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:md:mdformat" = {
        desc = "🔍 Lint 📝Markdown files with mdformat";
        cmds = [ ''mdformat --check "''${DEVENV_ROOT}"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };

      "ci:format:md:mdformat" = {
        aliases = [ "mdformat" ];
        desc = "🎨 Format 📝Markdown files with mdformat";
        cmds = [ ''mdformat "''${DEVENV_ROOT}"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
