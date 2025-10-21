{
  config,
  lib,
  pkgs,
  ...
}@args:
let
  inherit (lib.lists) map;
  recipes-lib = import ../../lib args;
  imports-args = args // {
    inherit
      config
      lib
      pkgs
      recipes-lib
      ;
  };

in
{
  imports = map (path: import path imports-args) [
    ./age.nix
    ./gitleaks.nix
    ./sops.nix
  ];

  options.biapy-recipes.secrets = recipes-lib.modules.mkModuleOptions "Secrets protection";
}
