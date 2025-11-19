args@{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.lists) map;
  inherit (lib.modules) mkIf mkDefault;

  cfg = config.biapy-recipes.config;
in
{
  imports = map (path: import path args) [
    ./json.nix
    ./toml.nix
    ./xml.nix
    ./yaml.nix
  ];

  options.biapy-recipes.config = recipes-lib.modules.mkModuleOptions "Config";

  config = mkIf cfg.enable {
    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:config" = mkDefault { desc = "🔍 Lint all 🔧configuration files"; };

      "ci:format:config" = mkDefault { desc = "🎨 Format 🔧configuration files"; };
    };
  };
}
