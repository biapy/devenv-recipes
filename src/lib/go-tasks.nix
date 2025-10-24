/**
  # go-tasks utilities

  This module provides utilities for creating and managing go-tasks in the
  devenv environment.
*/
{ recipes-lib, ... }:
let
  inherit (recipes-lib.attrsets) recursiveMerge;
in
{
  patchGoTask =
    task:
    recursiveMerge [
      {
        cmds = [
          {
            cmd = ''echo -e "\n\033[1;34m=== [{{.TASK}}]: ${task.desc} ===\033[0m"'';
            silent = true;
          }
        ];
        requires.vars = [ "DEVENV_ROOT" ];
        dir = "{{.DEVENV_ROOT}}";
      }
      task
    ];
}
