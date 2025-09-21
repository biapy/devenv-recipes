/**
  # terraform-docs

  terraform-docs generates Terraform modules documentation in various formats.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:docs:tf:terraform-docs`: Generate Terraform modules documentation files with `terraform-docs`.

  ## 🛠️ Tech Stack

  - [terraform-docs homepage](https://terraform-docs.io/).
  - [terraform-docs @ GitHub](https://github.com/terraform-docs/terraform-docs).

  ### 🧑‍💻 Visual Studio Code

  - [terraform-docs @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=DerekCAshmore.terraform-docs).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  utils = import ../utils {
    inherit config;
    inherit lib;
  };
  inherit (pkgs) terraform-docs;
  tfDocsCommand = lib.meta.getExe terraform-docs;
  initializeFilesTask = utils.tasks.initializeFilesTask {
    name = "terraform-docs";
    namespace = "terraform-docs";
    configFiles = {
      ".terraform-docs.yml" = ../files/terraform/.terraform-docs.yml;
    };
  };
in
{
  # https://devenv.sh/packages/
  packages = [ terraform-docs ];

  devcontainer.settings.customizations.vscode.extensions = [ "DerekCAshmore.terraform-docs" ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:docs:tf:terraform-docs" = {
      description = "Generate Terraform modules documentation files with terraform-docs";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${tfDocsCommand} --recursive "''${DEVENV_ROOT}"
      '';
    };
  }
  // initializeFilesTask;

}
