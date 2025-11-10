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

  Tasks automatically use `sops exec-env <envfile> tofu` when SOPS recipe is
  enabled, allowing secure access to encrypted secrets during Terraform
  operations. The env file path defaults to `.terraform.env` and can be
  configured via `biapy-recipes.secrets.sops.terraform-env-file`.

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
args@{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
  inherit (lib.lists) map;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.attrsets) optionalAttrs;
  inherit (recipes-lib.go-tasks) patchGoTask;

  cfg = config.biapy-recipes.terraform;
  sopsCfg = config.biapy-recipes.secrets.sops;

  opentofu = config.languages.opentofu.package;
  tofuCommand = lib.meta.getExe opentofu;

  # Use "sops exec-env <envfile> tofu" when sops is enabled, otherwise just "tofu"
  tofuExec =
    if sopsCfg.enable then "sops exec-env ${cfg.sops-env-file} ${tofuCommand}" else tofuCommand;
  tofuGoTask = if sopsCfg.enable then "sops exec-env ${cfg.sops-env-file} tofu" else "tofu";
in
{
  imports = map (path: import path args) [
    ./checkov.nix
    ./terraform-common.nix
    ./terraform-docs.nix
    ./tflint.nix
  ];

  options.biapy-recipes.terraform = (recipes-lib.modules.mkModuleOptions "Terraform") // {
    sops-env-file = mkOption {
      type = types.str;
      description = "Path to SOPS encrypted env file for Terraform/OpenTofu";
      default = "./terraform.env";
    };
  };

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
          ${tofuExec} fmt --recursive
        '';
      };

      "ci:lint:tf:tofu-validate" = {
        description = "🔍 Lint 🏗️OpenTofu files with tofu validate";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${tofuExec} validate
        '';
      };

      "reset:tf:tofu" = {
        description = "🔥 Delete 🏗️OpenTofu lock file and '.terraform' folder";
        exec = ''
          echo "Deleting OpenTofu '.terraform.lock.hcl' file"
          if [[ -e "''${DEVENV_ROOT}/.terraform.lock.hcl" ]]; then
            rm "''${DEVENV_ROOT}/.terraform.lock.hcl"
          fi

          echo "Deleting OpenTofu '.terraform' folder"
          if [[ -d "''${DEVENV_ROOT}/.terraform/" ]]; then
            rm -r "''${DEVENV_ROOT}/.terraform/"
          fi
        '';
        status = ''test ! -d "''${DEVENV_ROOT}/.terraform/"'';
      };

      "update:tf:tofu" = {
        description = "⬆️ Update 🏗️OpenTofu modules and providers";
        exec = ''
          cd "''${DEVENV_ROOT}"
          if [[ -e "''${DEVENV_ROOT}/.terraform.lock.hcl" ]]; then
            ${tofuExec} 'init' -upgrade
          fi
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
        cmds = [ ''${tofuGoTask} fmt --recursive'' ];
      };

      "ci:lint:tf:tofu-validate" = patchGoTask {
        aliases = [ "tf-validate" ];
        desc = "🔍 Lint 🏗️OpenTofu files with tofu validate";
        cmds = [ ''${tofuGoTask} validate'' ];
      };

      "reset:tf:tofu" = patchGoTask {
        desc = "🔥 Delete 🏗️OpenTofu lock file and '.terraform' folder";
        preconditions = [
          {
            sh = ''test -d "''${DEVENV_ROOT}/.terraform/"'';
            msg = "Project's '.terraform' folder does not exist, skipping.";
          }
          {
            sh = ''test -e "''${DEVENV_ROOT}/.terraform.lock.hcl"'';
            msg = "Project's '.terraform.lock.hcl' file does not exist, skipping.";
          }
        ];
        cmds = [
          ''echo "Deleting OpenTofu '.terraform.lock.hcl' file"''
          "[[ -e './.terraform.lock.hcl' ]] && rm -r './.terraform.lock.hcl' || true"
          ''echo "Deleting OpenTofu '.terraform' folder"''
          "[[ -d './.terraform/' ]] && rm -r './.terraform/' || true"
        ];
      };

      "update:tf:tofu" = patchGoTask {
        desc = "⬆️ Update 🏗️OpenTofu modules and providers";
        preconditions = [
          {
            sh = ''test -e "''${DEVENV_ROOT}/.terraform.lock.hcl"'';
            msg = "Project's .terraform.lock.hcl does not exist, skipping.";
          }
        ];
        cmds = [ ''${tofuGoTask} init -upgrade'' ];
      };
    };
  };
}
