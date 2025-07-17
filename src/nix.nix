{ pkgs, config, ... }:
let
  strict-nixfmt-tree = pkgs.nixfmt-tree.override { settings.formatter.nixfmt.options = "--strict"; };
in
{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    alejandra
    strict-nixfmt-tree
    nixos-anywhere
    nixos-rebuild
  ];

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  devcontainer.settings.customizations.vscode = {
    extensions = [
      "brettm12345.nixfmt-vscode"
      "bbenoist.Nix"
      "jnoortheen.nix-ide"
      "mkhl.direnv"
    ];
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    deadnix.enable = true;
    nil.enable = true;
    statix.enable = true;

    nixfmt-rfc-style = {
      enable = true;
    };
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:deadnix" = {
      description = "Lint *.nix files with deadnix";
      exec = ''${config.git-hooks.hooks.deadnix.package}/bin/deadnix --output-format 'json' > "$DEVENV_TASK_OUTPUT_FILE"'';
    };
    "ci:lint:statix" = {
      description = "Lint *.nix files with statix";
      exec = ''${config.git-hooks.hooks.statix.package}/bin/statix check --format 'json' > "$DEVENV_TASK_OUTPUT_FILE"'';
    };
    "ci:format:nixfmt" = {
      description = "Format *.nix files with nixfmt";
      exec = "${strict-nixfmt-tree}/bin/treefmt --tree-root '${config.env.DEVENV_ROOT}'";
    };
  };

}
