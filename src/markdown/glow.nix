/**
  # Glow

  Glow is a terminal based markdown reader designed from the ground up to bring
  out the beauty and power of the CLI.

  ## 🛠️ Tech Stack

  - [Glow @ GitHub](https://github.com/charmbracelet/glow).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.biapy.markdown;

  inherit (pkgs) glow;
in
{
  config = mkIf cfg.enable {

    # https://devenv.sh/packages/
    packages = [ glow ];
  };
}
