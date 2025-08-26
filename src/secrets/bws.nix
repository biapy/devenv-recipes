/**
  # Bitwarden Secrets Manager

  The Secrets Manager command-line interface (CLI) is a powerful tool for
  retrieving and injecting your secrets.
  The Secrets Manager CLI can be used to organize your vault with create,
  delete, edit, and list your secrets and projects.

  ## 🛠️ Tech Stack

  - [Secrets Manager CLI @ BitWarden]()
    ([Bitwarden Secrets Manager SDK @ GitHub](https://github.com/bitwarden/sdk-sm)).
*/
{ pkgs, ... }:
let
  inherit (pkgs) bws;
in
{
  imports = [ ./age.nix ];

  packages = [ bws ];
}
