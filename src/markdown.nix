{ pkgs, config, ... }:
let
  pythonPackages = pkgs.python313Packages;
in
{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    glow # TUI Markdown file viewer
  ];

  devcontainer.settings.customizations.vscode = {
    extensions = [ "DavidAnson.vscode-markdownlint" ];
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    # Markdown content
    markdownlint.enable = true;
    mdformat = {
      enable = true;
      package = pythonPackages.mdformat;
      extraPackages = with pythonPackages; [
        mdformat-admon
        mdformat-beautysh
        mdformat-footnote
        mdformat-frontmatter
        mdformat-gfm
        mdformat-mkdocs
        mdformat-myst
        mdformat-nix-alejandra
        mdformat-simple-breaks
        mdformat-tables
        mdformat-wikilink
      ];
    };

    cspell = {
      enable = true;
      files = ".*\.md$";
    };
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:markdownlint" =
      let
        inherit (config.git-hooks.hooks.markdownlint) package;
      in
      {
        description = "Lint *.md files with markdownlint";
        exec = ''
          set -o 'errexit' -o 'pipefail'
          ${package}/bin/markdownlint --json --output "$DEVENV_TASK_OUTPUT_FILE"
        '';
      };

    "ci:format:mdformat" =
      let
        inherit (config.git-hooks.hooks.mdformat) package;
      in
      {
        description = "Format *.md files with mdformat";
        exec = ''
          set -o 'errexit' -o 'pipefail'
          ${package}/bin/mdformat '${config.env.DEVENV_ROOT}'
        '';
      };

    "devenv-recipes:enterShell:configure:mdformat" = {
      description = "Create default .mdformat.toml if missing";
      before = [ "devenv:enterShell" ];
      exec = ''
        set -o 'errexit' -o 'pipefail'
        [[ -e '${config.env.DEVENV_ROOT}/.mdformat.toml' ]] ||
          tee '${config.env.DEVENV_ROOT}/.mdformat.toml' <<EOF
        # .mdformat.toml
        #
        wrap = "keep"       # possible values: {"keep", "no", INTEGER}
        number = true       # possible values: {false, true}
        end_of_line = "lf"  # possible values: {"lf", "crlf", "keep"}
        validate = true     # options: {false, true}

        extensions = [      # options: a list of enabled extensions (default: all installed are enabled)
          # "admon",
          # "footnote",
          "frontmatter",
          "gfm",
          # "mkdocs",
          # "myst",
          # "simple-breaks",
          "tables",
          "wikilink",
        ]

        # codeformatters = [  # options: a list of enabled code formatter languages (default: all installed are enabled)
        #     "bash",
        #     "json",
        #     "nix",
        #     "python",
        # ]

        exclude = []          # options: a list of file path pattern strings
        EOF
      '';

    };
  };

}
