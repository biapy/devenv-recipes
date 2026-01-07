{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.list) map;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.types) listOf str;

  cfg = config.biapy-recipes.tree-sitter;

  tree-sitter = cfg.package;

  tree-sitterWithGrammars = tree-sitter.withPlugins (
    grammars: map (language: grammars."tree-sitter-${language}") cfg.grammars
  );
in
{
  options.biapy-recipes.tree-sitter = {
    enable = mkEnableOption "Tree Sitter";
    package = mkPackageOption pkgs "Tree Sitter" { default = "tree-sitter"; };
    grammars = lib.mkOption {
      type = listOf str;
      default = [ ];
      description = "List of Tree Sitter grammars to include.";
    };
  };

  config = mkIf cfg.enable {
    packages = [ tree-sitterWithGrammars ];

    enterShell = ''
      echo "Tree Sitter: ${tree-sitterWithGrammars}"
    '';
  };
}
