/**
  # Terrascan

  Terrascan is a static code analyzer for Infrastructure as Code.
  It detects compliance and security violations across Infrastructure as Code
  to mitigate risk before provisioning cloud native infrastructure.

  :::warning
  Terrascan is currently unmaintained.
  Consider using Checkov or other alternatives.
  :::

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:tf:terrascan`: scan IaC configuration with `terrascan`.

  ### 👷 Commit hooks

  - `terrascan`: scan IaC configuration with `terrascan`,
    disabled by default, as Terrascan is unmaintained.

  ## 🛠️ Tech Stack

  - [Terrascan homepage](https://runterrascan.io/).
  - [Terrascan @ GitHub](https://github.com/tenable/terrascan).

  ## 🙇 Acknowledgements

  - [What is Terrascan? Features, Use Cases & Custom Policies @ spacelift](https://spacelift.io/blog/what-is-terrascan).
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
  cfg = terraformCfg.terrascan;

  inherit (pkgs) terrascan;
  terrascanCommand = lib.meta.getExe terrascan;
in
{
  options.biapy-recipes.terraform.terrascan = mkToolOptions terraformCfg "terrascan";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ terrascan ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks {
      terrascan = {
        enable = false;
        name = "Terrascan";
        package = terrascan;
        pass_filenames = false;
        entry = ''${terrascanCommand} "scan"'';
      };
    };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:lint:tf:terrascan" = {
        description = "Lint Infrastructure as Code with terrascan";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${terrascanCommand} 'scan' --iac-type 'terraform'
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:tf:terrascan" = {
        aliases = [ "terrascan" ];
        desc = "Lint Infrastructure as Code with terrascan";
        cmds = [ ''terrascan 'scan' --iac-type "terraform"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
