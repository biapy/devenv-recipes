args@{ lib, recipes-lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [
    ./beautysh.nix
    ./shell.nix
    ./shellcheck.nix
    ./shfmt.nix
  ];

  options.biapy-recipes.shell = recipes-lib.modules.mkModuleOptions "Shell";
}
