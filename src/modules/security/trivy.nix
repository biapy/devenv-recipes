/**
  # Trivy

  Trivy is a comprehensive and versatile security scanner.
  Trivy has scanners that look for security issues,
  and targets where it can find those issues.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:trivy:fs`: Check local filesystem with `trivy`.
  - `ci:lint:trivy:config`: Check local configuration files with `trivy`.

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
  pkgs-unstable,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (config.devenv) root;

  securityCfg = config.biapy-recipes.security;
  cfg = securityCfg.trivy;

  inherit (pkgs-unstable) trivy;
  trivyCommand = lib.meta.getExe trivy;
in
{
  options.biapy-recipes.security.trivy = mkToolOptions securityCfg "Trivy";

  config = mkIf cfg.enable {

    # https://devenv.sh/packages/
    packages = [ trivy ];

    devcontainer.settings.customizations.vscode.extensions = [
      "AquaSecurityOfficial.trivy-vulnerability-scanner"
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks {
      trivy-fs = {
        enable = true;
        name = "Trivy local filesystem audit";
        package = trivy;
        pass_filenames = false;
        entry = ''${trivyCommand} 'fs' "${root}"'';
      };

      trivy-config = {
        enable = true;
        name = "Trivy configuration audit";
        package = trivy;
        pass_filenames = false;
        entry = ''${trivyCommand} 'config' "${root}"'';
      };
    };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:lint:trivy:fs" = {
        description = "Lint local filesystem with trivy";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${trivyCommand} 'fs' "''${DEVENV_ROOT}"
        '';
      };

      "ci:lint:trivy:config" = {
        description = "Lint local configuration files with trivy";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${trivyCommand} 'config' "''${DEVENV_ROOT}"
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:trivy".aliases = [ "trivy" ];
      "ci:lint:trivy:fs" = {
        desc = "Lint local filesystem with trivy";
        cmds = [ ''${trivyCommand} 'fs' "''${DEVENV_ROOT}"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };

      "ci:lint:trivy:config" = {
        desc = "Lint local configuration files with trivy";
        cmds = [ ''${trivyCommand} 'config' "''${DEVENV_ROOT}"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
