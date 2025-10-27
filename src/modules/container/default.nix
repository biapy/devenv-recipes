args@{ lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [ ./hadolint.nix ];
}
