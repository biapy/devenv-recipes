args@{ lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [
    ./ansible
    ./config
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
    ./twig
    ./devcontainer.nix
    ./git.nix
    ./gnu-parallel.nix
  ];
}
