/**
  # GitLeaks

  Gitleaks is a tool for detecting secrets like passwords, API keys,
  and tokens in git repos, files, and via `stdin`.

  ## 🛠️ Tech Stack

  - [Gitleaks homepage](https://gitleaks.io/)
  - [Gitleaks @ GitHub](https://github.com/gitleaks/gitleaks).
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
  inherit (recipes-lib.tasks) mkInitializeFilesTask;

  secretsCfg = config.biapy-recipes.secrets;
  cfg = secretsCfg.gitleaks;

  gitleaks = cfg.package;
  gitleaksCommand = lib.meta.getExe gitleaks;

  gitleaksInitializeFilesTask = mkInitializeFilesTask {
    name = "gitleaks";
    namespace = "gitleaks";
    configFiles = {
      ".gitleaks.toml" = ../../files/secrets/.gitleaks.toml;
    };
  };
in
{
  options.biapy-recipes.secrets.gitleaks = mkToolOptions secretsCfg "gitleaks" // {
    package = mkPackageOption pkgs "gitleaks" { };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      gitleaks = {
        enable = mkDefault true;
        package = mkDefault gitleaks;
        pass_filenames = false;
        entry = "${gitleaksCommand} dir";
      };
    };

    # https://devenv.sh/tasks/
    tasks =
      gitleaksInitializeFilesTask
      // optionalAttrs cfg.tasks {
        "ci:secops:secrets:gitleaks:git" = {
          description = "🕵️‍♂️ Check for 🔐secrets leaks in Git repository with gitleaks";
          exec = ''
            set -o 'errexit'
            ${gitleaksCommand} --report-format='json' --report-path="$DEVENV_TASK_OUTPUT_FILE" 'git'
          '';
        };

        "ci:secops:secrets:gitleaks:dir" = {
          description = "🕵️‍♂️ Check for 🔐secrets leaks in project files with gitleaks";
          exec = ''
            set -o 'errexit'
            ${gitleaksCommand} --report-format='json' --report-path="$DEVENV_TASK_OUTPUT_FILE" 'dir'
          '';
        };
      };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:secops:secrets:gitleaks".aliases = [ "gitleaks" ];
      "ci:secops:secrets:gitleaks:git" = patchGoTask {
        desc = "🕵️‍♂️ Check for 🔐secrets leaks in Git repository with gitleaks";
        cmds = [ "gitleaks 'git'" ];
      };

      "ci:secops:secrets:gitleaks:dir" = patchGoTask {
        desc = "🕵️‍♂️ Check for 🔐secrets leaks in project files with gitleaks";
        cmds = [ "gitleaks 'dir'" ];
      };
    };
  };
}
