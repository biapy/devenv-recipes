args@{ lib, recipes-lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [
    ./json.nix
    ./toml.nix
    ./xml.nix
    ./yaml.nix
  ];

  options.biapy-recipes.config = recipes-lib.modules.mkModuleOptions "Config";
}
