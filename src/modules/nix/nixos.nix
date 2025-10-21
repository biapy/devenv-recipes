{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;

  nixCfg = config.biapy-recipes.nix;
  cfg = nixCfg.nixos;
in
{
  options.biapy-recipes.nix.nixos.enable = mkOption {
    type = types.bool;
    description = "Enable nixos-rebuild integration";
    default = false;
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = with pkgs; [
      nixos-anywhere
      nixos-rebuild
      nixos-rebuild-ng
    ];
  };
}
