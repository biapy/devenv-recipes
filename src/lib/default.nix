{ lib, ... }:
rec {
  attrsets = import ./attrsets.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib; };
  tasks = import ./tasks.nix { };
  sops = import ./sops.nix { inherit lib; };
  go-tasks = import ./go-tasks.nix {
    inherit lib;
    recipes-lib = { inherit attrsets; };
  };
}
