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
    nixdoc
    fd
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
    "ci:lint:nix:deadnix" =
      let
        inherit (config.git-hooks.hooks.deadnix) package;
      in
      {
        description = "Lint *.nix files with deadnix";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${package}/bin/deadnix --output-format 'json' > "''${DEVENV_TASK_OUTPUT_FILE}"
        '';
      };
    "ci:lint:nix:statix" =
      let
        inherit (config.git-hooks.hooks.statix) package;
      in
      {
        description = "Lint *.nix files with statix";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${package}/bin/statix check --format 'json' > "''${DEVENV_TASK_OUTPUT_FILE}"
        '';
      };
    "ci:lint:nix:nil" =
      let
        inherit (config.git-hooks.hooks.nil) package;
      in
      {
        description = "Lint *.nix files with nil";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${pkgs.fd}/bin/fd '\.nix$' "''${DEVENV_ROOT}" --exec ${package}/bin/nil diagnostics -- {}
        '';
      };
    "ci:format:nix:nixfmt" = {
      description = "Format *.nix files with nixfmt";
      exec = ''
        set -o 'errexit' -o 'pipefail'

        cd "''${DEVENV_ROOT}"
        ${strict-nixfmt-tree}/bin/treefmt --tree-root "''${DEVENV_ROOT}"
      '';
    };
  };

}
