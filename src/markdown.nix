{ pkgs, ... }:

{

  devcontainer.settings.customizations.vscode = {
    extensions = [ "DavidAnson.vscode-markdownlint" ];
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    # Markdown content
    markdownlint.enable = true;
    mdformat = {
      enable = true;
      package = pkgs.pythonPackages.mdformat;
      extraPackages = with pkgs.pythonPackages; [
        mdformat-frontmatter
        mdformat-tables
      ];
    };

    cspell = {
      enable = true;
      files = ".*\.md$";
    };
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:markdownlint" = {
      description = "Lint *.md files with markdownlint";
      exec = "${pkgs.markdownlint}/bin/markdownlint";
    };
    "ci:lint".after = [ "ci:lint:markdownlint" ];

  };

  files.".mdformat".toml = ''
    # .mdformat.toml
    #
    # This file shows the default values and is equivalent to having
    # no configuration file at all. Change the values for non-default
    # behavior.
    #
    wrap = "keep"       # possible values: {"keep", "no", INTEGER}
    number = true       # possible values: {false, true}
    end_of_line = "lf"  # possible values: {"lf", "crlf", "keep"}

  '';
}
