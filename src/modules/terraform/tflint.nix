/**
  # TFLint

  TFLint is a framework and each feature is provided by plugins, the key features are as follows:

  - Find possible errors (like invalid instance types) for Major Cloud providers (AWS/Azure/GCP).
  - Warn about deprecated syntax, unused declarations.
  - Enforce best practices, naming conventions.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:tf:tflint`: Lint `.tf` files with `tflint`.

  ### 👷 Commit hooks

  - `tflint`: Lint `.tf` files with `tflint`.

  ## 🛠️ Tech Stack

  - [terraform-docs @ GitHub](https://github.com/terraform-linters/tflint).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
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

  terraformCfg = config.biapy-recipes.terraform;
  cfg = terraformCfg.tflint;

  inherit (pkgs) tflint;
  tflintCommand = lib.meta.getExe tflint;
in
{
  options.biapy-recipes.terraform.tflint = mkToolOptions terraformCfg "tflint";

  config = mkIf cfg.enable {
    packages = [ tflint ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks { tflint.enable = true; };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:lint:tf:tflint" = {
        description = "Lint *.tf files with tflint";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${tflintCommand} --chdir="''${DEVENV_ROOT}"
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:tf:tflint" = {
        aliases = [ "tflint" ];
        desc = "Lint *.tf files with tflint";
        cmds = [ ''tflint --chdir="''${DEVENV_ROOT}"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
