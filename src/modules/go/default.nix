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
  inherit (recipes-lib.modules) mkToolOptions;

  cfg = config.biapy-recipes.go;
  goCommand = lib.meta.getExe config.languages.go.package;
in
{
  imports = map (path: import path args) [ ];

  options.biapy-recipes.go = mkToolOptions "Go";

  config = mkIf cfg.enable {
    # https://devenv.sh/languages/
    languages.go.enable = true;

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      gofmt.enable = mkDefault true;
      govet.enable = mkDefault true;
      # golangci-lint = mkDefault true;
      # golines.enable = mkDefault true;
      # gotest.enable = mkDefault true;
      # revive.enable = mkDefault true;
      # staticcheck = mkDefault true;
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {

      "ci:lint:go:vet" = mkDefault {
        description = "🔍 Lint 🐹Go files with `vet`";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${goCommand} 'vet'
        '';
      };

      "ci:fix:go:fix" = mkDefault {
        description = "🧹 Fix 🐹Go files with `fix`";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${goCommand} 'fix'
        '';
      };

      "ci:format:go:gofmt" = mkDefault {
        description = "🎨 Format 🐹Go files with `gofmt`";
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
      "ci:lint:go:vet" = mkDefault {
        desc = "🔍 Lint 🐹Go files with `vet`";
        cmds = [ "go 'vet'" ];
      };

      "ci:fix:go:fix" = mkDefault {
        desc = "🧹 Fix 🐹Go files with `fix`";
        cmds = [ "go 'fix'" ];
      };

      "ci:format:go:go-fmt" = patchGoTask {
        desc = "🎨 Format 🐹Go files with `gofmt`";
        cmds = [ "go 'fmt'" ];
      };

      "cd:build:go:go-build" = patchGoTask {
        aliases = [ "go-tidy" ];
        desc = "🔨 Build 🐹Go sources with `go build`";
        cmds = [ "go 'build'" ];
      };

      "update:go:tidy" = patchGoTask {
        aliases = [ "go-tidy" ];
        desc = "⬆️ Update 🐹Go modules with `go mod tidy`";
        cmds = [ "go 'mod' 'tidy'" ];
      };

      "ci:secops:go:verify" = patchGoTask {
        aliases = [ "go-verify" ];
        desc = "🕵️‍♂️ Verify 🐹Go modules with `go mod verify`";
        cmds = [ "go 'mod' 'verify'" ];
      };
    };
  };
}
