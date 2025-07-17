{ pkgs, config, ... }:

{
  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    gitleaks = rec {
      enable = true;
      package = pkgs.gitleaks;
      pass_filenames = false;
      entry = "${package}/bin/gitleaks git";
    };
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:secops:gitleaks" = {
      description = "Check for secrets leaks with gitleaks";
      exec = "${config.git-hooks.hooks.gitleaks.package}/bin/gitleaks --report-format='json' --report-path=$DEVENV_TASK_OUTPUT_FILE git";
    };
  };
}
