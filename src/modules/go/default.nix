args@{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.lists) map;
  inherit (lib.attrsets) optionalAttrs;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.modules) mkModuleOptions;

  cfg = config.biapy-recipes.go;
  goCommand = lib.meta.getExe config.languages.go.package;
in
{
  imports = map (path: import path args) [ ];

  options.biapy-recipes.go = mkModuleOptions "Go";

  config = mkIf cfg.enable {
    # https://devenv.sh/languages/
    languages.go.enable = true;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      nixfmt-rfc-style = {
        enable = mkDefault true;
        args = mkDefault [ "--strict" ];
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:format:go:go-fmt" = mkDefault {
        description = "🎨 Format 🐹Go files with `go fmt`";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${goCommand} 'fmt'
        '';
      };

      "cd:build:go:go-build" = mkDefault {
        description = "🔨 Build 🐹Go sources with `go build`";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          if [[ -e "''${DEVENV_ROOT}/go.mod" ]]; then
            ${goCommand} 'build'
          fi
        '';
      };

      "update:go:tidy" = mkDefault {
        description = "⬆️ Update 🐹Go modules with `go mod tidy`";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          if [[ -e "''${DEVENV_ROOT}/go.mod" ]]; then
            ${goCommand} 'mod' 'tidy'
          fi
        '';
      };

      "ci:secops:go:verify" = mkDefault {
        description = "🕵️‍♂️ Verify 🐹Go modules with `go mod verify`";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          if [[ -e "''${DEVENV_ROOT}/go.mod" ]]; then
            ${goCommand} 'mod' 'verify'
          fi
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:format:go:go-fmt" = patchGoTask {
        aliases = [ "go-fmt" ];
        desc = "🎨 Format 🐹Go files with `go fmt`";
        cmds = [ "go fmt" ];
      };

      "cd:build:go:go-build" = patchGoTask {
        aliases = [ "go-tidy" ];
        desc = "🔨 Build 🐹Go sources with `go build`";
        preconditions = [
          {
            sh = ''test -e "''${DEVENV_ROOT}/go.mod"'';
            msg = "Project's 'go.mod' does not exist, skipping.";
          }
        ];
        cmds = [ "go 'build'" ];
      };

      "update:go:tidy" = patchGoTask {
        aliases = [ "go-tidy" ];
        desc = "⬆️ Update 🐹Go modules with `go mod tidy`";
        preconditions = [
          {
            sh = ''test -e "''${DEVENV_ROOT}/go.mod"'';
            msg = "Project's 'go.mod' does not exist, skipping.";
          }
        ];
        cmds = [ "go 'mod' 'tidy'" ];
      };

      "ci:secops:go:verify" = patchGoTask {
        aliases = [ "go-verify" ];
        desc = "🕵️‍♂️ Verify 🐹Go modules with `go mod verify`";
        preconditions = [
          {
            sh = ''test -e "''${DEVENV_ROOT}/go.mod"'';
            msg = "Project's 'go.mod' does not exist, skipping.";
          }
        ];
        cmds = [ "go 'mod' 'verify'" ];
      };
    };
  };
}
