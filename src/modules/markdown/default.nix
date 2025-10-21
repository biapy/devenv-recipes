{
  config,
  lib,
  pkgs,
  ...
}@args:
let
  inherit (lib.lists) map;
  recipes-lib = import ../../lib args;
  imports-args = {
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
    ./cspell.nix
    ./glow.nix
    ./markdownlint.nix
    ./mdformat.nix
  ];

  options.biapy-recipes.markdown = recipes-lib.modules.mkModuleOptions "Markdown";
}
