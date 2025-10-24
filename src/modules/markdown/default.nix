args@{ lib, recipes-lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [
    ./cspell.nix
    ./glow.nix
    ./markdownlint.nix
    ./mdformat.nix
  ];

  options.biapy-recipes.markdown = recipes-lib.modules.mkModuleOptions "Markdown";
}
