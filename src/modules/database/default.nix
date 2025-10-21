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
  imports = map (path: import path imports-args) [ ./postgresql.nix ];

  options.biapy-recipes.database = recipes-lib.modules.mkModuleOptions "database";

}
