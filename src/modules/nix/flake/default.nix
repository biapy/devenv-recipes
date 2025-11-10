/**
  # Nix Flakes

  Support for Nix flakes management and validation.

  ## 🧐 Features

  - Flake checker for health checks
  - Flake lock file updates

  ## 🛠️ Tech Stack

  - [Nix Flakes @ NixOS Wiki](https://nixos.wiki/wiki/Flakes).
*/
args@{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [
    ./flake-checker.nix
    ./flake-update.nix
  ];

  options.biapy-recipes.nix.flake = recipes-lib.modules.mkModuleOptions "Nix Flakes";
}
