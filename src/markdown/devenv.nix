{ config, lib, ... }:
let
  inherit (lib)
    types
    mkOption
    mkIf
    mkDefault
    ;

  cfg = config.biapy.markdown;
in
{
  imports = [
    ./cspell.nix
    ./glow.nix
    ./markdownlint.nix
    ./mdformat.nix
  ];

  options.biapy.markdown = {
    enable = mkOption {
      type = types.bool;
      description = "Enable Markdown devenv recipe";
      default = false;
    };

    go-task = mkOption {
      type = types.bool;
      description = "Enable Markdown Taskfile tasks";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:format:md" = mkDefault {
        desc = "Format Markdown files";
        vars = {
          TASKS = {
            sh = lib.strings.concatStringsSep " | " [
              "task --json --list-all"
              "jq --raw-output '.tasks[].name'"
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
      "ci:lint:md" = mkDefault {
        desc = "Lint Markdown files";
        vars = {
          TASKS = {
            sh = lib.strings.concatStringsSep " | " [
              "task --json --list-all"
              "jq --raw-output '.tasks[].name'"
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
