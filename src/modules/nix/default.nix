args@{ recipes-lib, ... }:

{
  imports = map (path: import path args) [
    ./deadnix.nix
    ./flake
    ./nil.nix
    ./nixdoc.nix
    ./nixos.nix
    ./nix.nix
    ./nixfmt.nix
    ./statix.nix
  ];

  options.biapy-recipes.nix = recipes-lib.modules.mkModuleOptions "Nix";
}
