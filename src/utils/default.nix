{ config }:
{
  tasks = import ./tasks.nix { inherit config; };
  composer-bin = import ./composer-bin.nix { inherit config; };
}
