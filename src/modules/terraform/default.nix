/**
  # Terraform module
*/
args@{ recipes-lib, ... }:
{
  imports = map (path: import path args) [
    ./checkov.nix
    ./opentofu.nix
    ./terraform-common.nix
    ./terraform-docs.nix
    ./terragrunt.nix
    ./tflint.nix
  ];

  options.biapy-recipes.terraform = recipes-lib.modules.mkModuleOptions "Terraform";

}
