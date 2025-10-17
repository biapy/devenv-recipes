{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
  inherit (pkgs) jq;

  jqCommand = lib.meta.getExe jq;
in
{
  imports = [
    ./markdown
    ./nix
  ];

  config = {
    packages = [ jq ];
    biapy.go-task.taskfile.tasks = {
      "ci:format" = mkDefault {
        aliases = [
          "ci:fmt"
          "format"
          "fmt"
        ];
        desc = "Format all supported files";
        vars = {
          TASKS = {
            sh = lib.strings.concatStringsSep " | " [
              "task --json --list-all"
              "${jqCommand} --raw-output '.tasks[].name'"
              "grep --only-matching --extended-regexp '{{.TASK}}:[^:]+$'"
            ];
          };
        };
        cmds = [
          {
            for = {
              var = "TASKS";
            };
            cmd = "task '{{.ITEM}}'";
          }
        ];
        silent = true;
        requires.vars = [ "DEVENV_ROOT" ];
      };
      "ci:lint" = mkDefault {
        aliases = [ "lint" ];
        desc = "Lint all supported files";
        vars = {
          TASKS = {
            sh = lib.strings.concatStringsSep " | " [
              "task --json --list-all"
              "${jqCommand} --raw-output '.tasks[].name'"
              "grep --only-matching --extended-regexp '{{.TASK}}:[^:]+$'"
            ];
          };
        };
        cmds = [
          {
            for = {
              var = "TASKS";
            };
            cmd = "task '{{.ITEM}}'";
          }
        ];
        silent = true;
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
