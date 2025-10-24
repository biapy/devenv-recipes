args@{ recipes-lib, ... }:

{
  imports = map (path: import path args) [
    ./deadnix.nix
    ./flake-checker.nix
    ./nil.nix
    ./nixos.nix
    ./nix.nix
    ./nixfmt.nix
    ./statix.nix
  ];

  options.biapy-recipes.nix = recipes-lib.modules.mkModuleOptions "Nix";
}
