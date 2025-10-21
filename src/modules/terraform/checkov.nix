/**
  # Checkov

  Checkov scans cloud infrastructure configurations to find misconfigurations
  before they're deployed.
  It prevent cloud misconfigurations
  and find vulnerabilities during build-time in infrastructure as code,
  container images, and open source packages.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:tf:checkov`: Inspect IaC configuration with `checkov`.

  ### 👷 Commit hooks

  - `checkov`: scan IaC configuration with `checkov`.

  ## 🛠️ Tech Stack

  - [Checkov homepage](https://www.checkov.io/).
  - [Checkov @ GitHub](https://github.com/bridgecrewio/checkov).

  ## 🙇 Acknowledgements

  - [Checkov vérifie votre code d'infrastructure
    @ Culture et Outils DevSecOps :fr:](https://blog.stephane-robert.info/docs/securiser/outils/checkov/).
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

  terraformCfg = config.biapy-recipes.terraform;
  cfg = terraformCfg.checkov;

  inherit (config.devenv) root;
  inherit (pkgs-unstable) checkov;
  checkovCommand = lib.meta.getExe checkov;
in
{
  options.biapy-recipes.terraform.checkov = mkToolOptions terraformCfg "checkov";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ checkov ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks {
      checkov = {
        enable = true;
        name = "Checkov";
        package = checkov;
        pass_filenames = false;
        entry = ''${checkovCommand} --directory "${root}"'';
      };
    };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:lint:tf:checkov" = {
        description = "Inspect Infrastructure as Code with checkov";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${checkovCommand} --directory "''${DEVENV_ROOT}"
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:tf:checkov" = {
        aliases = [ "checkov" ];
        desc = "Inspect Infrastructure as Code with checkov";
        cmds = [ ''checkov --directory "''${DEVENV_ROOT}"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
