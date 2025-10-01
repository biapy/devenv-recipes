/**
  # Security tools

  ## 🛠️ Tech Stack

  - [Syft @ GitHub](https://github.com/anchore/syft).
  - [Grype @ GitHub](https://github.com/anchore/grype).
*/
{ pkgs, ... }:
{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    grype
    syft
  ];
}
