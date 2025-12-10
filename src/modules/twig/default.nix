args@{ lib, recipes-lib, ... }:
let
  inherit (lib.lists) map filter;
  inherit (lib.strings) hasSuffix;
  inherit (lib.filesystem) listFilesRecursive;

  php-recipe-lib = import ./lib.nix args;

  imports-args = args // {
    inherit php-recipe-lib;
  };

  # List all files recursively in the directory
  allFiles = listFilesRecursive ./.;

  # Filter for `.nix` files
  nixFiles = filter (path: hasSuffix ".nix" path && path != ./default.nix) allFiles;
in
{
  imports = map (path: import path imports-args) nixFiles;

  options.biapy-recipes.twig = recipes-lib.modules.mkModuleOptions "Twig";
}
