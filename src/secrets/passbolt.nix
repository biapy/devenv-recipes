/**
  # Passbolt CLI

  A CLI tool to interact with Passbolt,
  a Open source Password Manager for Teams.

  ## 🛠️ Tech Stack

  - [go-passbolt-cli @ GitHub](https://github.com/passbolt/go-passbolt-cli).
*/
{ pkgs, ... }:
let
  inherit (pkgs) go-passbolt-cli;
in
{
  imports = [ ./age.nix ];

  packages = [ go-passbolt-cli ];
}
