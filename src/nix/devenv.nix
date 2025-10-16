{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  imports = [
    ./deadnix.nix
    ./flake-checker.nix
    ./nil.nix
    ./nixos.nix
    ./nix.nix
    ./nixfmt.nix
    ./statix.nix
  ];

  options.biapy.nix = {
    enable = mkOption {
      type = types.bool;
      description = "Enable Nix devenv recipe";
      default = false;
    };
  };
}
