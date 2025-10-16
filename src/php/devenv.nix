{ config, lib, ... }:
let
  inherit (lib) types mkOption;

  cfg = config.biapy.php;
in
{
  options.biapy.php = {
    enable = mkOption {
      type = types.bool;
      description = "Enable PHP devenv recipe";
      default = false;
    };
  };

  config = lib.mkIf cfg.enable { imports = [ ./default.nix ]; };
}
