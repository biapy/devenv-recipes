/**
  # TFLint

  TFLint is a framework and each feature is provided by plugins, the key features are as follows:

  - Find possible errors (like invalid instance types) for Major Cloud providers (AWS/Azure/GCP).
  - Warn about deprecated syntax, unused declarations.
  - Enforce best practices, naming conventions.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:format:tf:tflint`: Lint `.tf` files with `tflint`.

  ### 👷 Commit hooks

  - `tflint`: Lint `.tf` files with `tflint`.

  ## 🛠️ Tech Stack

  - [terraform-docs @ GitHub](https://github.com/terraform-linters/tflint).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) tflint;
  tflintCommand = lib.meta.getExe tflint;
in
{
  packages = [ tflint ];

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.tflint.enable = true;

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:tf:tflint" = {
      description = "Lint *.tf files with tflint";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${tflintCommand} --chdir="''${DEVENV_ROOT}"
      '';
    };
  };
}
