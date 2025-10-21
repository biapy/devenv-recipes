/**
  # Biapy devenv-recipes modules functions
*/
{ lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (lib.strings) isString;
  inherit (lib.attrsets) mergeAttrsList;
in
rec {
  mkModuleOptions =
    name:
    assert isString name;
    {
      enable = mkOption {
        type = types.bool;
        description = "Enable ${name} devenv recipe";
        default = false;
      };

      go-task = mkOption {
        type = types.bool;
        description = "Enable ${name} Taskfile tasks";
        default = true;
      };
    };

  mkToolOptions =
    cfg: name:
    assert isString name;
    mergeAttrsList [
      (mkEnableOption cfg name)
      (mkGitHooksOption name)
      (mkTasksOption name)
      (mkGoTaskOption name)
    ];

  mkEnableOption =
    cfg: name:
    assert isString name;
    {
      enable = mkOption {
        type = types.bool;
        description = "Enable ${name} integration";
        default = cfg.enable;
      };
    };

  mkGitHooksOption =
    name:
    assert isString name;
    {
      git-hooks = mkOption {
        type = types.bool;
        description = "Enable ${name} git hooks";
        default = true;
      };
    };

  mkTasksOption =
    name:
    assert isString name;
    {
      tasks = mkOption {
        type = types.bool;
        description = "Enable ${name} devenv tasks";
        default = true;
      };
    };

  mkGoTaskOption =
    name:
    assert isString name;
    {
      go-task = mkOption {
        type = types.bool;
        description = "Enable ${name} Taskfile tasks";
        default = true;
      };
    };
}
