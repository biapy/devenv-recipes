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
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.tasks) mkInitializeFilesTask;
  inherit (lib.attrsets) optionalAttrs;

  terraformCfg = config.biapy-recipes.terraform;
  cfg = terraformCfg.terraform-docs;

  inherit (pkgs) terraform-docs;
  tfDocsCommand = lib.meta.getExe terraform-docs;

  initializeFilesTask = mkInitializeFilesTask {
    name = "terraform-docs";
    namespace = "terraform-docs";
    configFiles = {
      ".terraform-docs.yml" = ../files/terraform/.terraform-docs.yml;
    };
  };
in
{
  options.biapy-recipes.terraform.terraform-docs = mkToolOptions terraformCfg "terraform-docs";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ terraform-docs ];

    devcontainer.settings.customizations.vscode.extensions = [ "DerekCAshmore.terraform-docs" ];

    # https://devenv.sh/tasks/
    tasks =
      (optionalAttrs cfg.tasks {
        "ci:docs:tf:terraform-docs" = {
          description = "📚 Generate 🏗️Terraform modules documentation files with terraform-docs";
          exec = ''
            cd "''${DEVENV_ROOT}"
            ${tfDocsCommand} --recursive "''${DEVENV_ROOT}"
          '';
        };
      })
      // initializeFilesTask;

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:docs:tf:terraform-docs" = {
        aliases = [
          "terraform-docs"
          "tfdocs"
        ];
        desc = "📚 Generate 🏗️Terraform modules documentation files with terraform-docs";
        cmds = [ ''terraform-docs --recursive "''${DEVENV_ROOT}"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
