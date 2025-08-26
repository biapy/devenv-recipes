/**
  # terraform-docs

  terraform-docs generates Terraform modules documentation in various formats.

  ## 🛠️ Tech Stack

  - [terraform-docs homepage](https://terraform-docs.io/).
  - [terraform-docs @ GitHub](https://github.com/terraform-docs/terraform-docs).

  ### 🧑‍💻 Visual Studio Code

  - [terraform-docs @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=DerekCAshmore.terraform-docs).
*/
{ pkgs, ... }:
let
  inherit (pkgs) terraform-docs;
in
{
  # https://devenv.sh/packages/
  packages = [ terraform-docs ];

  devcontainer.settings.customizations.vscode.extensions = [ "DerekCAshmore.terraform-docs" ];

}
