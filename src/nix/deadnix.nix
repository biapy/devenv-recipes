/**
  # Deadnix

  Deadnix scans `.nix` files for dead code (unused variable bindings).

  ## 🛠️ Tech Stack

  - [deadnix @ GitHub](https://github.com/astro/deadnix).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.deadnix @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksdeadnix).
*/
{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkDefault
    mkOption
    types
    ;

  nixCfg = config.biapy.nix;
  cfg = nixCfg.deadnix;

  deadnix = config.git-hooks.hooks.deadnix.package;
  deadnixCommand = lib.meta.getExe deadnix;
in
{
  options.biapy.nix.deadnix = {
    enable = mkOption {
      type = types.bool;
      description = "Enable deadnix integration";
      default = true;
    };

    git-hooks = mkOption {
      type = types.bool;
      description = "Enable deadnix git hooks";
      default = true;
    };

    tasks = mkOption {
      type = types.bool;
      description = "Enable deadnix devenv tasks";
      default = true;
    };

    go-task = mkOption {
      type = types.bool;
      description = "Enable deadnix Taskfile tasks";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    packages = [ deadnix ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks { deadnix.enable = true; };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:lint:nix:deadnix" = {
        description = "Lint *.nix files with deadnix";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          '${deadnixCommand}' --fail
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:nix:deadnix" = mkDefault {
        aliases = [ "deadnix" ];
        desc = "Lint *.nix files with deadnix";
        cmds = [ "'${deadnixCommand}' --fail" ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
