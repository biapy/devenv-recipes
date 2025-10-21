{
  config,
  lib,
  pkgs,
  nixpkgs-unstable,
  ...
}@args:
let
  inherit (lib.lists) map;

  pkgs-unstable = import nixpkgs-unstable { inherit (pkgs.stdenv) system; };
  recipes-lib = import ../../lib args;
  imports-args = args // {
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
    ./checkov.nix
    ./opentofu.nix
    ./terraform-common.nix
    ./terraform-docs.nix
    ./tflint.nix
  ];

  options.biapy-recipes.terraform = recipes-lib.modules.mkModuleOptions "Terraform";
}
