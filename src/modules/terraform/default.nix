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

  Tasks automatically use `sops exec-env "<envfile>" "<command>"` when SOPS
  recipe is enabled, allowing secure access to encrypted secrets during
  Terraform operations. The env file path defaults to `./terraform.env` and can
  be configured via `biapy-recipes.terraform.sops-env-file`.

  ### 👷 Commit hooks

  - `terraform-format`: Format Terraform (`.tf`) files.
  - `terraform-validate`: Validates terraform configuration files (`.tf`).

  ## 🛠️ Tech Stack

  - [OpenTofu homepage](https://opentofu.org/).

  ### 🧑‍💻 Visual Studio Code

  - [OpenTofu (official) @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=OpenTofu.vscode-opentofu).

  ## 🙇 Acknowledgements

  - [languages.opentofu @ devenv](https://devenv.sh/reference/options/#languagesopentofuenable).
  - [Cloud Development Kit for Terraform](https://developer.hashicorp.com/terraform/cdktf).
*/
args@{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.lists) map;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.options) mkOption;
  inherit (lib) types;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.sops) wrapWithSopsExecEnv;

  cfg = config.biapy-recipes.terraform;
  sopsCfg = config.biapy-recipes.secrets.sops;

  opentofu = config.languages.opentofu.package;
  tofuCommand = getExe opentofu;

  # Helper to wrap tofu commands with sops exec-env when enabled
  wrapTofu =
    command:
    wrapWithSopsExecEnv {
      sopsEnabled = sopsCfg.enable;
      envFile = cfg.sops-env-file;
      inherit command;
    };
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

    # https://devenv.sh/scripts/
    scripts.tf = {
      description = mkDefault "OpenTofu";
      packages = mkDefault [ opentofu ];
      exec = mkDefault ''
        exec ${tofuCommand} "$@";
      '';
    };

    # https://devenv.sh/tasks/
    tasks = {
      "ci:format:tf:tofu-fmt" = {
        description = mkDefault "🎨 Format 🏗️OpenTofu files";
        exec = mkDefault ''
          cd "''${DEVENV_ROOT}"
          ${wrapTofu "${tofuCommand} fmt --recursive"}
        '';
      };

      "ci:lint:tf:tofu-validate" = {
        description = mkDefault "🔍 Lint 🏗️OpenTofu files with tofu validate";
        exec = mkDefault ''
          cd "''${DEVENV_ROOT}"
          ${wrapTofu "${tofuCommand} validate"}
        '';
      };

      "reset:tf:tofu" = {
        description = mkDefault "🔥 Delete 🏗️OpenTofu lock file and '.terraform' folder";
        exec = mkDefault ''
          echo "Deleting OpenTofu '.terraform.lock.hcl' file"
          if [[ -e "''${DEVENV_ROOT}/.terraform.lock.hcl" ]]; then
            rm "''${DEVENV_ROOT}/.terraform.lock.hcl"
          fi

          echo "Deleting OpenTofu '.terraform' folder"
          if [[ -d "''${DEVENV_ROOT}/.terraform/" ]]; then
            rm -r "''${DEVENV_ROOT}/.terraform/"
          fi
        '';
        status = mkDefault ''test ! -d "''${DEVENV_ROOT}/.terraform/"'';
      };

      "update:tf:tofu" = {
        description = mkDefault "⬆️ Update 🏗️OpenTofu modules and providers";
        exec = mkDefault ''
          cd "''${DEVENV_ROOT}"
          if [[ -e "''${DEVENV_ROOT}/.terraform.lock.hcl" ]]; then
            ${wrapTofu "${tofuCommand} init -upgrade"}
          fi
        '';
      };
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = {
      terraform-format = {
        enable = mkDefault true;
        inherit (config.languages.opentofu) package;
      };
      terraform-validate = {
        enable = mkDefault true;
        inherit (config.languages.opentofu) package;
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:format:tf:tofu-fmt" = patchGoTask {
        aliases = mkDefault [ "tf-fmt" ];
        desc = mkDefault "🎨 Format 🏗️OpenTofu files";
        cmds = mkDefault [ "${wrapTofu "tofu fmt --recursive"}" ];
      };

      "ci:lint:tf:tofu-validate" = patchGoTask {
        aliases = mkDefault [ "tf-validate" ];
        desc = mkDefault "🔍 Lint 🏗️OpenTofu files with tofu validate";
        cmds = mkDefault [ "${wrapTofu "tofu validate"}" ];
      };

      "reset:tf:tofu" = patchGoTask {
        desc = mkDefault "🔥 Delete 🏗️OpenTofu lock file and '.terraform' folder";
        preconditions = mkDefault [
          {
            sh = ''test -d "''${DEVENV_ROOT}/.terraform/"'';
            msg = "Project's '.terraform' folder does not exist, skipping.";
          }
          {
            sh = ''test -e "''${DEVENV_ROOT}/.terraform.lock.hcl"'';
            msg = "Project's '.terraform.lock.hcl' file does not exist, skipping.";
          }
        ];
        cmds = mkDefault [
          ''echo "Deleting OpenTofu '.terraform.lock.hcl' file"''
          "[[ -e './.terraform.lock.hcl' ]] && rm -r './.terraform.lock.hcl' || true"
          ''echo "Deleting OpenTofu '.terraform' folder"''
          "[[ -d './.terraform/' ]] && rm -r './.terraform/' || true"
        ];
      };

      "update:tf:tofu" = patchGoTask {
        desc = mkDefault "⬆️ Update 🏗️OpenTofu modules and providers";
        preconditions = mkDefault [
          {
            sh = ''test -e "''${DEVENV_ROOT}/.terraform.lock.hcl"'';
            msg = "Project's .terraform.lock.hcl does not exist, skipping.";
          }
        ];
        cmds = mkDefault [ "${wrapTofu "tofu init -upgrade"}" ];
      };
    };
  };
}
