args@{ lib, recipes-lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [
    ./cspell.nix
    ./glow.nix
    ./lychee.nix
    ./markdownlint.nix
    ./marksman.nix
    ./mdformat.nix
    ./vale.nix
  ];

  options.biapy-recipes.markdown = recipes-lib.modules.mkModuleOptions "Markdown";
}
