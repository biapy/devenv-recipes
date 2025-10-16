{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;

  nixCfg = config.biapy.nix;
  cfg = nixCfg.nixos;
in
{
  options.biapy.nix.nixos.enable = mkOption {
    type = types.bool;
    description = "Enable Nixfmt integration";
    default = nixCfg.enable;
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
