{
  pkgs,
  config,
  inputs,
  ...
}:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv) system; };
in
{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    alejandra
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

    flake-checker = {
      enable = true;
      package = pkgs-unstable.flake-checker;
    };

    nixfmt-rfc-style = {
      enable = true;
    };
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:deadnix" = {
      description = "Lint *.nix files with deadnix";
      exec = "${pkgs.deadnix}/bin/deadnix";
    };
    "ci:lint:statix" = {
      description = "Lint *.nix files with statix";
      exec = "${pkgs.statix}/bin/statix check";
    };
    "ci:format:nixfmt" = {
      description = "Lint *.nix files with statix";
      exec = "${pkgs.nixfmt-rfc-style}/bin/nixfmt --strict ${config.env.DEVENV_ROOT}";
    };
    "ci:lint".after = [
      "ci:lint:deadnix"
      "ci:lint:statix"
    ];
    "ci:format".after = [ "ci:format:nixfmt" ];
  };

}
