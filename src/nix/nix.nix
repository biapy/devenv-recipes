{ pkgs, ... }:
{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    alejandra
    nixos-anywhere
    nixos-rebuild
    nixos-rebuild-ng
    nixdoc
  ];

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  devcontainer.settings.customizations.vscode.extensions = [
    "bbenoist.Nix"
    "mkhl.direnv"
  ];
}
