/**
  # Semgrep

  Semgrep is a fast, open-source, static analysis tool for finding bugs,
  detecting dependency vulnerabilities, and enforcing code standards.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:security:semgrep`: Scan code with `semgrep`.

  ### 👷 Commit hooks

  - `semgrep`: Scan code with `semgrep`.

  ## 🛠️ Tech Stack

  - [Semgrep homepage](https://semgrep.dev/).
  - [Semgrep @ GitHub](https://github.com/semgrep/semgrep).

  ### 🧑‍💻 Visual Studio Code

  - [Semgrep @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=Semgrep.semgrep).

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
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkPackageOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  securityCfg = config.biapy-recipes.security;
  cfg = securityCfg.semgrep;

  semgrep = cfg.package;
  semgrepCommand = lib.meta.getExe' semgrep "semgrep";
in
{
  options.biapy-recipes.security.semgrep = mkToolOptions securityCfg "Semgrep" // {
    package = mkPackageOption pkgs "semgrep" { };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ semgrep ];

    devcontainer.settings.customizations.vscode.extensions = [ "Semgrep.semgrep" ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      semgrep = {
        enable = mkDefault true;
        name = "Semgrep scan";
        package = semgrep;
        pass_filenames = false;
        entry = "${semgrepCommand} scan --config=auto";
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:security:semgrep" = {
        description = "🔍 Scan code with semgrep";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${semgrepCommand} scan --config=auto
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:security:semgrep" = patchGoTask {
        aliases = [ "semgrep" ];
        desc = "🔍 Scan code with semgrep";
        cmds = [ "semgrep scan --config=auto" ];
      };
    };
  };
}
