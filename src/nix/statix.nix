/**
  # Statix

  statix provides linting and suggestions for the Nix programming language.

  - `statix check` highlights antipatterns in Nix code.
  - `statix fix` can fix several such occurrences.

  ## 🛠️ Tech Stack

  - [statix @ git.peppe.rs](https://git.peppe.rs/languages/statix/about/).
  - [statix @ GitHub](https://github.com/oppiliappan/statix).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.statix @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksstatix).
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
  cfg = nixCfg.statix;

  statix = config.git-hooks.hooks.statix.package;
  statixCommand = lib.meta.getExe statix;
in
{
  options.biapy.nix.statix = {
    enable = mkOption {
      type = types.bool;
      description = "Enable statix integration";
      default = nixCfg.enable;
    };

    git-hooks = mkOption {
      type = types.bool;
      description = "Enable statix git hooks";
      default = true;
    };

    tasks = mkOption {
      type = types.bool;
      description = "Enable statix devenv tasks";
      default = true;
    };

    go-task = mkOption {
      type = types.bool;
      description = "Enable statix Taskfile tasks";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    packages = [ statix ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks { statix.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:lint:nix:statix" = mkDefault {
        description = "Lint *.nix files with statix";
        exec = ''
          set -o 'errexit'

          cd "''${DEVENV_ROOT}"
          ${statixCommand} check
        '';
      };
      "ci:format:nix:statix" = mkDefault {
        description = "Fix *.nix files with statix";
        exec = ''
          set -o 'errexit'

          cd "''${DEVENV_ROOT}"
          ${statixCommand} fix
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:nix:statix" = mkDefault {
        aliases = [ "statix" ];
        desc = "Lint *.nix files with statix";
        cmds = [ ''${statixCommand} check'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };

      "ci:format:nix:statix" = mkDefault {
        aliases = [ "statix-fix" ];
        desc = "Fix *.nix files with statix";
        cmds = [ ''${statixCommand} fix'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
