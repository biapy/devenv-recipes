/**
  # Glow

  Glow is a terminal based markdown reader designed from the ground up to bring
  out the beauty and power of the CLI.

  ## 🛠️ Tech Stack

  - [Glow @ GitHub](https://github.com/charmbracelet/glow).
*/
{ pkgs, ... }:
let
  inherit (pkgs) glow;
in
{
  # https://devenv.sh/packages/
  packages = [ glow ];
}
