/**
  # Terragrunt

   Terragrunt is a flexible orchestration tool that allows Infrastructure as Code written in
   OpenTofu/Terraform to scale.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:tf:terragrunt-validate`: Lint Terragrunt files with `terragrunt validate`.

  ### 👷 Commit hooks

  - `terragrunt-validate`: Validates Terragrunt (`.hcl`) and Terraform files (`.tf`).

  ## 🛠️ Tech Stack

  - [Terragrunt homepage](https://terragrunt.gruntwork.io/).
  - [Terragrunt @ GitHub](https://github.com/gruntwork-io/terragrunt).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkDefault mkIf;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  terraformCfg = config.biapy-recipes.terraform;
  cfg = terraformCfg.terragrunt;

  inherit (pkgs) terragrunt;
  terragruntCommand = getExe terragrunt;
in
{
  options.biapy-recipes.terraform.terragrunt = mkToolOptions terraformCfg "terragrunt";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ terragrunt ];

    # https://devenv.sh/scripts/
    scripts.tg = {
      description = mkDefault "Terragrunt";
      packages = mkDefault [ terragrunt ];
      exec = mkDefault ''
        exec ${terragruntCommand} "$@";
      '';
    };

    # https://devenv.sh/git-hooks/
    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      terragrunt-validate = {
        enable = mkDefault true;
        name = mkDefault "Terragrunt validate";
        package = mkDefault terragrunt;
        files = "\\.(hcl|tf)$";
        pass_filenames = mkDefault false;
        entry = mkDefault ''${terragruntCommand} "validate"'';
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:tf:terragrunt-validate" = {
        description = mkDefault "🔍 Lint 🏗️Terragrunt and OpenTofu files with terragrunt validate";
        exec = mkDefault ''
          cd "''${DEVENV_ROOT}"
          ${terragruntCommand} 'validate'
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:tf:terragrunt-validate" = patchGoTask {
        aliases = mkDefault [ "tg-validate" ];
        desc = mkDefault "🔍 Lint 🏗️Terragrunt and OpenTofu files with terragrunt validate";
        cmds = mkDefault [ "terragrunt validate" ];
      };

    };
  };
}
