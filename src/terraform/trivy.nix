/**
  # Trivy

  Trivy is a comprehensive and versatile security scanner.
  Trivy has scanners that look for security issues,
  and targets where it can find those issues.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:secops:trivy:fs`: Check local filesystem with `trivy`.
  - `ci:secops:trivy:config`: Check local configuration files with `trivy`.

  ### 👷 Commit hooks

  - `trivy-fs`: Check local filesystem with `trivy`.
  - `trivy-config`: Check local configuration files with `trivy`.

  ## 🛠️ Tech Stack

  - [Trivy homepage](https://trivy.dev/latest/).
  - [Trivy @ GitHub](https://github.com/aquasecurity/trivy).

  ### 🧑‍💻 Visual Studio Code

  - [Aqua Trivy @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=AquaSecurityOfficial.trivy-vulnerability-scanner).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.devenv) root;
  inherit (pkgs) trivy;
  trivyCommand = lib.meta.getExe trivy;
in
{
  # https://devenv.sh/packages/
  packages = [ trivy ];

  devcontainer.settings.customizations.vscode.extensions = [
    "AquaSecurityOfficial.trivy-vulnerability-scanner"
  ];

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    trivy-fs = {
      enable = true;
      name = "Trivy local filesystem audit";
      package = trivy;
      pass_filenames = false;
      entry = ''${trivyCommand} 'fs' "''${DEVENV_ROOT}"'';
    };

    trivy-config = {
      enable = true;
      name = "Trivy configuration audit";
      package = trivy;
      pass_filenames = false;
      entry = ''${trivyCommand} 'config' "''${DEVENV_ROOT}"'';
    };
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:secops:trivy:fs" = {
      description = "Lint local filesystem with trivy";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${trivyCommand} 'fs' "${root}"
      '';
    };
    "ci:secops:trivy:config" = {
      description = "Lint local configuration files with trivy";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${trivyCommand} 'config' "${root}"
      '';
    };
  };
}
