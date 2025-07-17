{ pkgs, inputs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv) system; };
in
{
  imports = [ ./nix.nix ];

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    flake-checker = {
      enable = true;
      package = pkgs-unstable.flake-checker;
    };
  };
}
