{ pkgs, ... }:
{
  imports = [ ./nix.nix ];

  # https://devenv.sh/packages/
  packages = with pkgs; [
    nixos-anywhere
    nixos-rebuild
    nixos-rebuild-ng
  ];
}
