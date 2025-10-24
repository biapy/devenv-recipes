/**
  # OpenTofu

  OpenTofu is a reliable, flexible, community-driven
  infrastructure as code tool under the Linux Foundation's stewardship.
  It serves as a drop-in replacement for Terraform,
  preserving existing workflows and configurations.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:format:tf:tofu-fmt`: Format OpenTofu files `tofu fmt`.
  - `ci:lint:tf:tofu-validate`: Lint OpenTofu files with `tofu validate`.

  ### 👷 Commit hooks

  - `terraform-format`: Format Terraform (`.tf`) files.
  - `terraform-validate`: Validates terraform configuration files (`.tf`).

  ## 🛠️ Tech Stack

  - [OpenTofu homepage](https://opentofu.org/).

  ### 🧑‍💻 Visual Studio Code

  - [OpenTofu (official) @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=OpenTofu.vscode-opentofu).

  ## 🙇 Acknowledgements

  - [languages.opentofu @ devenv](https://devenv.sh/reference/options/#languagesopentofuenable).
  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [Cloud Development Kit for Terraform](https://developer.hashicorp.com/terraform/cdktf).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.attrsets) optionalAttrs;
  inherit (recipes-lib.go-tasks) patchGoTask;

  cfg = config.biapy-recipes.terraform;

  opentofu = config.languages.opentofu.package;
  tofuCommand = lib.meta.getExe opentofu;
in
{
  config = mkIf cfg.enable {

    # https://devenv.sh/languages/
    languages.opentofu.enable = true;

    env.TERRAFORM_BINARY_NAME = tofuCommand;

    devcontainer.settings.customizations.vscode.extensions = [ "OpenTofu.vscode-opentofu" ];

    # https://devenv.sh/tasks/
    tasks = {
      "ci:format:tf:tofu-fmt" = {
        description = "🎨 Format 🏗️OpenTofu files";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${tofuCommand} fmt --recursive
        '';
      };
      "ci:lint:tf:tofu-validate" = {
        description = "🔍 Lint 🏗️OpenTofu files with tofu validate";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${tofuCommand} validate
        '';
      };
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = {
      terraform-format.enable = mkDefault true;
      terraform-validate.enable = mkDefault true;
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:format:tf:tofu-fmt" = patchGoTask {
        aliases = [ "tf-fmt" ];
        desc = "🎨 Format 🏗️OpenTofu files";
        cmds = [ ''tofu fmt --recursive'' ];
      };

      "ci:lint:tf:tofu-validate" = patchGoTask {
        aliases = [ "tf-validate" ];
        desc = "🔍 Lint 🏗️OpenTofu files with tofu validate";
        cmds = [ ''tofu validate'' ];
      };
    };
  };
}
