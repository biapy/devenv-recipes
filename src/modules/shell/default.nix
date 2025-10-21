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
    ./beautysh.nix
    ./shell.nix
    ./shellcheck.nix
    ./shfmt.nix
  ];

  options.biapy-recipes.shell = recipes-lib.modules.mkModuleOptions "Shell";
}
