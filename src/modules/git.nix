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
  inherit (pkgs) lazygit;

  cfg = config.biapy-recipes.git;

  git = cfg.package;
in
{

  options.biapy-recipes.git = mkToolOptions config.biapy-recipes "Git" // {
    package = mkPackageOption pkgs "Git" { default = "git"; };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [
      git
      lazygit # Git terminal UI
    ];

    # https://devenv.sh/integrations/difftastic/
    difftastic.enable = true;

    # https://devenv.sh/integrations/delta/
    delta.enable = true;

    enterShell = ''
      git --version
      lazygit --version
    '';

    # https://devenv.sh/tasks/
    tasks = {
      "biapy-recipes:enterTest:git-version" = {
        description = "Test available git command version match devenv git package";
        before = [ "devenv:enterTest" ];
        exec = ''
          set -o 'errexit' -o 'pipefail'
          git --version | grep --color=auto "${git.version}"
        '';
      };
    };

    # https://taskfile.dev/usage/#variables
    biapy.go-task.taskfile.vars = optionalAttrs cfg.go-task {
      GIT_COMMIT = mkDefault { sh = "git log -n 1 --format=%H 2>/dev/null || echo 'unknown'"; };
      GIT_COMMIT_SHORT = mkDefault { sh = "git log -n 1 --format=%h 2>/dev/null || echo 'unknown'"; };
      GIT_TAG = mkDefault { sh = "git describe --tags --exact-match 2>/dev/null || echo ''"; };
      GIT_BRANCH = mkDefault { sh = "git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown'"; };
      GIT_STATE = mkDefault {
        sh = "git diff --quiet && git diff --cached --quiet && echo 'clean' || echo 'dirty'";
      };
      GIT_AUTHOR = mkDefault { sh = "git log -n 1 --format=%an 2>/dev/null || echo 'unknown'"; };
      GIT_AUTHOR_EMAIL = mkDefault { sh = "git log -n 1 --format=%ae 2>/dev/null || echo 'unknown'"; };
      GIT_COMMIT_DATE = mkDefault { sh = "git log -n 1 --format=%ci 2>/dev/null || echo 'unknown'"; };
    };
  };
}
