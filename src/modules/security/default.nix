/**
  # Security tools

  ## 🛠️ Tech Stack

  - [Syft @ GitHub](https://github.com/anchore/syft).
  - [Grype @ GitHub](https://github.com/anchore/grype).
*/
args@{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib.lists) map;
  inherit (lib.modules) mkIf;

  cfg = config.biapy-recipes.security;
in
{
  imports = map (path: import path args) [ ./trivy.nix ];

  options.biapy-recipes.security = recipes-lib.modules.mkModuleOptions "Security and Supply Chain";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = with pkgs; [
      grype
      syft
    ];
  };
}
