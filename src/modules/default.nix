args@{ lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [
    ./ansible
    ./container
    ./database
    ./go
    ./markdown
    ./nix
    ./php
    ./security
    ./secrets
    ./shell
    ./terraform
    ./devcontainer.nix
    ./git.nix
    ./gnu-parallel.nix
  ];
}
