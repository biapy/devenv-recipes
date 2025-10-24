args@{ lib, recipes-lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [
    ./age.nix
    ./gitleaks.nix
    ./sops.nix
  ];

  options.biapy-recipes.secrets = recipes-lib.modules.mkModuleOptions "Secrets protection";
}
