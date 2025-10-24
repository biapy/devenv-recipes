{ lib, ... }:
rec {
  attrsets = import ./attrsets.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib; };
  tasks = import ./tasks.nix { };
  go-tasks = import ./go-tasks.nix {
    inherit lib;
    recipes-lib = { inherit attrsets; };
  };
}
