{ pkgs, config, ... }:
let
  pythonPackages = pkgs.python313Packages;
in
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
      package = pythonPackages.mdformat;
      extraPackages = with pythonPackages; [
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
      exec = ''${config.git-hooks.hooks.markdownlint.package}/bin/markdownlint --json --output "$DEVENV_TASK_OUTPUT_FILE"'';
    };
    "ci:format:mdformat" = {
      description = "Format *.md files with mdformat";
      exec = "${config.git-hooks.hooks.mdformat.package}/bin/mdformat '${config.env.DEVENV_ROOT}'";
    };
  };

  files.".mdformat".toml = {
    wrap = "keep"; # possible values: {"keep", "no", INTEGER}
    number = true; # possible values: {false, true}
    end_of_line = "lf"; # possible values: {"lf", "crlf", "keep"}
  };
}
