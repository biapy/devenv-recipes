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
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkPackageOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (config.devenv) root;

  securityCfg = config.biapy-recipes.security;
  cfg = securityCfg.trivy;

  trivy = cfg.package;
  trivyCommand = lib.meta.getExe trivy;
in
{
  options.biapy-recipes.security.trivy = mkToolOptions securityCfg "Trivy" // {
    package = mkPackageOption pkgs-unstable "trivy" { };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ trivy ];

    devcontainer.settings.customizations.vscode.extensions = [
      "AquaSecurityOfficial.trivy-vulnerability-scanner"
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      trivy-fs = {
        enable = mkDefault true;
        name = "Trivy local filesystem audit";
        package = trivy;
        pass_filenames = false;
        entry = ''${trivyCommand} 'fs' "${root}"'';
      };

      trivy-config = {
        enable = mkDefault true;
        name = "Trivy configuration audit";
        package = trivy;
        pass_filenames = false;
        entry = ''${trivyCommand} 'config' "${root}"'';
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:secops:security:trivy:fs" = {
        description = "🕵️‍♂️ Check local filesystem with trivy";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${trivyCommand} 'fs' "''${DEVENV_ROOT}"
        '';
      };

      "ci:secops:security:trivy:config" = {
        description = "🕵️‍♂️ Check local configuration files with trivy";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${trivyCommand} 'config' "''${DEVENV_ROOT}"
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:secops:security:trivy".aliases = [ "trivy" ];
      "ci:secops:security:trivy:fs" = patchGoTask {
        desc = "🕵️‍♂️ Check local filesystem with trivy";
        cmds = [ "trivy 'fs' './'" ];
      };

      "ci:secops:security:trivy:config" = patchGoTask {
        desc = "🕵️‍♂️ Check local configuration files with trivy";
        cmds = [ "trivy 'config' './'" ];
      };
    };
  };
}
