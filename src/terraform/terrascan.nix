/**
  # Terrascan

  Terrascan is a static code analyzer for Infrastructure as Code.
  It detects compliance and security violations across Infrastructure as Code
  to mitigate risk before provisioning cloud native infrastructure.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:tf:terrascan`: scan IaC configuration with `terrascan`.

  ### 👷 Commit hooks

  - `terrascan`: scan IaC configuration with `terrascan`.

  ## 🛠️ Tech Stack

  - [Terrascan homepage](https://runterrascan.io/).
  - [Terrascan @ GitHub](https://github.com/tenable/terrascan).

  ## 🙇 Acknowledgements

  - [What is Terrascan? Features, Use Cases & Custom Policies @ spacelift](https://spacelift.io/blog/what-is-terrascan).
  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) terrascan;
  terrascanCommand = lib.meta.getExe terrascan;
in
{
  # https://devenv.sh/packages/
  packages = [ terrascan ];

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    terrascan = {
      enable = true;
      name = "Terrascan";
      package = terrascan;
      pass_filenames = false;
      entry = ''${terrascanCommand} "scan"'';
    };
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:tf:terrascan" = {
      description = "Lint Infrastructure as Code with terrascan";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${terrascanCommand} 'scan'
      '';
    };
  };
}
