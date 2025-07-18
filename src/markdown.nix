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

    "devenv-recipes:enterShell:ignore-mdformat-toml" = {
      description = "Add .mdformat.toml to .gitignore";
      before = [ "devenv:enterShell" ];
      exec = ''
        set -o 'errexit' -o 'pipefail'
        grep --quiet '^.mdformat.toml$' '${config.env.DEVENV_ROOT}/.gitignore' ||
          tee --append '${config.env.DEVENV_ROOT}/.gitignore' <<EOF

        # Ignore .mdformat.toml, part of the "markdown.nix" Biapy devenv recipe
        .mdformat.toml

        EOF
      '';
    };
  };

  files = {
    # https://mdformat.readthedocs.io/en/stable/users/configuration_file.html
    ".mdformat.toml".toml = {
      wrap = "keep"; # possible values: {"keep", "no", INTEGER}
      number = true; # possible values: {false, true}
      end_of_line = "lf"; # possible values: {"lf", "crlf", "keep"}
    };
  };
}
