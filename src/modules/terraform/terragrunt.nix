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
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.tasks) mkGitIgnoreTask;

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
    scripts = {
      tg = {
        description = mkDefault "Terragrunt";
        packages = mkDefault [ terragrunt ];
        exec = mkDefault ''
          exec ${terragruntCommand} "$@";
        '';
      };
      tg-validate = {
        description = mkDefault "Validate Terragrunt files with terragrunt validate";
        packages = mkDefault [ terragrunt ];
        exec = mkDefault ''
          tg-validate() {
            if [[ $# -ne 1 ]]; then
              echo "Usage: tg-validate <file.hcl>"
              return 1
            fi

            local file="''${1}"

            if [[ ! -f "$file" ]]; then
              echo "Error: File ''${file} does not exist."
              return 1
            fi

            if [[ ! "''${file}" =~ \.hcl$ ]]; then
              echo "Warning: File ''${file} is not an .hcl file."
              return 0
            fi

            echo "Validating ''${file}..."
            ${terragruntCommand} --working-dir "$(dirname "''${file}")" run validate || return 1
          }

          for file in "''${@}"; do
            tg-validate "''${file}" || exit 1
          done

          echo "Usage: tg-validate <file.hcl>"
          exit 1
        '';
      };
    };

    treefmt.config.programs.hclfmt = {
      enable = mkDefault true;
    };

    # https://devenv.sh/git-hooks/
    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      terragrunt-validate = {
        enable = mkDefault true;
        name = mkDefault "terragrunt-validate";
        package = mkDefault terragrunt;
        files = mkDefault "*\\.(tf|hcl)$";
        pass_filenames = mkDefault false;
        entry = mkDefault "${terragruntCommand} run --all -- 'validate'";
      };
    };

    # https://devenv.sh/tasks/
    tasks =
      (optionalAttrs cfg.tasks {
        "ci:lint:tf:terragrunt-validate" = {
          description = mkDefault "🔍 Lint 🏗️Terragrunt and OpenTofu files with terragrunt validate";
          exec = mkDefault ''
            cd "''${DEVENV_ROOT}"
            ${terragruntCommand} run --all -- 'validate'
          '';
        };
      })
      // mkGitIgnoreTask {
        name = "terragrunt";
        namespace = "tf:terragrunt";
        ignoredPaths = [
          # terragrunt cache directories
          "**/.terragrunt-cache/*"

          # Terragrunt debug output file (when using `--terragrunt-debug` option)
          # See: https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-debug
          "terragrunt-debug.tfvars.json"

          # End of https://www.toptal.com/developers/gitignore/api/terraform,terragrunt

          # Terragrunt generated files
          "**/_*.tf"
          ".terragrunt-stack"
        ];
      };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:tf:terragrunt-validate" = patchGoTask {
        aliases = mkDefault [ "tg-validate" ];
        desc = mkDefault "🔍 Lint 🏗️Terragrunt files with terragrunt validate";
        cmds = mkDefault [ "terragrunt run --all -- validate" ];
      };

      "update:tf:terragrunt" = patchGoTask {
        aliases = mkDefault [
          "update:terragrunt"
          "up:tg"
          "up:tf:terragrunt"
          "up:tf:tg"
          "tg-upgrade"
          "tg-up"
        ];
        desc = mkDefault "⬆️ Update 🏗️Terragrunt stacks";
        cmds = mkDefault [ "terragrunt run --all -- init --upgrade" ];
      };

      "ci:format:tf:hclfmt" = patchGoTask {
        aliases = mkDefault [
          "hclfmt"
          "format:tf:hclfmt"
          "format:hclfmt"
        ];
        desc = mkDefault "🎨 Format 🏗️Terragrunt files with hclfmt";
        cmds = mkDefault [ "treefmt --formatters='hclfmt'" ];
      };
    };

  };
}
