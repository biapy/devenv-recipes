{
  config,
  lib,
  pkgs,
  nixpkgs-unstable,
  ...
}@args:
let
  inherit (lib.lists) map;
  recipes-lib = import ../../lib args;
  pkgs-unstable = import nixpkgs-unstable { inherit (pkgs.stdenv) system; };

  imports-args = {
    inherit
      config
      lib
      pkgs
      pkgs-unstable
      recipes-lib
      ;
  };

in
{
  imports = map (path: import path imports-args) [
    ./deadnix.nix
    ./flake-checker.nix
    ./nil.nix
    ./nixos.nix
    ./nix.nix
    ./nixfmt.nix
    ./statix.nix
  ];

  options.biapy-recipes.nix = recipes-lib.modules.mkModuleOptions "Nix";
}
