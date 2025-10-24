args@{ lib, recipes-lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [
    ./checkov.nix
    ./opentofu.nix
    ./terraform-common.nix
    ./terraform-docs.nix
    ./tflint.nix
  ];

  options.biapy-recipes.terraform = recipes-lib.modules.mkModuleOptions "Terraform";
}
