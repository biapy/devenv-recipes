/**
  # terraform-docs

  terraform-docs generates Terraform modules documentation in various formats.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:format:tf:tflint`: Lint `.tf` files with `tflint`.

  ## 🛠️ Tech Stack

  - [terraform-docs homepage](https://terraform-docs.io/).
  - [terraform-docs @ GitHub](https://github.com/terraform-docs/terraform-docs).

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
