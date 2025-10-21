{ lib, ... }:
{
  modules = import ./modules.nix { inherit lib; };
  tasks = import ./tasks.nix { };
}
