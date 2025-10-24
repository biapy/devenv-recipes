args@{ lib, recipes-lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [ ./postgresql.nix ];

  options.biapy-recipes.database = recipes-lib.modules.mkModuleOptions "database";

}
