/**
    # Nixfmt

  Nixfmt is the official formatter for Nix language code.

    ## 🛠️ Tech Stack

    - [Nixfmt @ GitHub](https://github.com/NixOS/nixfmt).
    - [treefmt homepage](https://treefmt.com/latest/)
      ([treefmt @ GitHub](https://github.com/numtide/treefmt)).
    - [nixfmt-tree @ NixPkgs' GitHub](https://github.com/NixOS/nixpkgs/tree/nixos-25.05/pkgs/by-name/ni/nixfmt-tree).

    ## 🙇 Acknowledgements

    - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
    - [git-hooks.hooks.nixfmt-rfc-style @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksnixfmt-rfc-style).
*/
{
  pkgs,
  lib,
  ...
}:
let
  strict-nixfmt-tree = pkgs.nixfmt-tree.override { settings.formatter.nixfmt.options = "--strict"; };
  nixfmtTreeCommand = lib.meta.getExe strict-nixfmt-tree;
in
{
  imports = [ ./nix.nix ];

  # https://devenv.sh/packages/
  packages = [
    strict-nixfmt-tree
  ];

  devcontainer.settings.customizations.vscode.extensions = [
    "brettm12345.nixfmt-vscode"
  ];

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.nixfmt-rfc-style = {
    enable = true;
  };

  # https://devenv.sh/tasks/
  tasks."ci:format:nix:nixfmt" = {
    description = "Format *.nix files with nixfmt";
    exec = ''
      set -o 'errexit' -o 'pipefail'

      cd "''${DEVENV_ROOT}"
      ${nixfmtTreeCommand} --tree-root "''${DEVENV_ROOT}"
    '';
  };

}
