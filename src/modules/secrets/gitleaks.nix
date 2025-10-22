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
  inherit (pkgs) gitleaks;
  inherit (lib.modules) mkIf;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (lib.attrsets) optionalAttrs;

  secretsCfg = config.biapy-recipes.secrets;
  cfg = secretsCfg.gitleaks;

  gitleaksCommand = lib.meta.getExe gitleaks;
in
{
  options.biapy-recipes.secrets.gitleaks = mkToolOptions secretsCfg "gitleaks";

  config = mkIf cfg.enable {
    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      gitleaks = {
        enable = true;
        package = gitleaks;
        pass_filenames = false;
        entry = "${gitleaksCommand} dir";
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:secrets:gitleaks:git" = {
        description = "Check for secrets leaks in Git repository with gitleaks";
        exec = ''
          set -o 'errexit'
          ${gitleaksCommand} --report-format='json' --report-path="$DEVENV_TASK_OUTPUT_FILE" 'git'
        '';
      };

      "ci:lint:secrets:gitleaks:dir" = {
        description = "Check for secrets leaks in project files with gitleaks";
        exec = ''
          set -o 'errexit'
          ${gitleaksCommand} --report-format='json' --report-path="$DEVENV_TASK_OUTPUT_FILE" 'dir'
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:secrets:gitleaks:git" = {
        desc = "Check for secrets leaks in Git repository with gitleaks";
        cmds = [ "gitleaks 'git'" ];
        requires.vars = [ "DEVENV_ROOT" ];
      };

      "ci:lint:secrets:gitleaks:dir" = {
        desc = "Check for secrets leaks in project files with gitleaks";
        cmds = [ "gitleaks 'dir'" ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
