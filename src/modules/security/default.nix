/**
  # Security tools

  ## 🛠️ Tech Stack

  - [Syft @ GitHub](https://github.com/anchore/syft).
  - [Grype @ GitHub](https://github.com/anchore/grype).
*/
{
  config,
  lib,
  pkgs,
  nixpkgs-unstable,
  ...
}@args:
let
  inherit (lib.lists) map;
  inherit (lib.modules) mkIf;

  pkgs-unstable = import nixpkgs-unstable { inherit (pkgs.stdenv) system; };
  recipes-lib = import ../../lib args;

  imports-args = {
    inherit
      config
      lib
      pkgs
      recipes-lib
      pkgs-unstable
      ;
  };

  cfg = config.biapy-recipes.security;
in
{
  imports = map (path: import path imports-args) [ ./trivy.nix ];

  options.biapy-recipes.security = recipes-lib.modules.mkModuleOptions "Security and Supply Chain";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = with pkgs; [
      grype
      syft
    ];
  };
}
