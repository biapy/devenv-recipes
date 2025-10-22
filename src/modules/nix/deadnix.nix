/**
  # Deadnix

  Deadnix scans `.nix` files for dead code (unused variable bindings).

  ## 🛠️ Tech Stack

  - [deadnix @ GitHub](https://github.com/astro/deadnix).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.deadnix @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksdeadnix).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (lib.attrsets) optionalAttrs;

  nixCfg = config.biapy-recipes.nix;
  cfg = nixCfg.deadnix;

  deadnix = config.git-hooks.hooks.deadnix.package;
  deadnixCommand = lib.meta.getExe deadnix;
in
{
  options.biapy-recipes.nix.deadnix = mkToolOptions nixCfg "deadnix";

  config = mkIf cfg.enable {
    packages = [ deadnix ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks { deadnix.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:nix:deadnix" = {
        description = "🔍 Lint ❄️Nix files with deadnix";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          '${deadnixCommand}' --fail
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:nix:deadnix" = mkDefault {
        aliases = [ "deadnix" ];
        desc = "🔍 Lint ❄️Nix files with deadnix";
        cmds = [ "deadnix --fail" ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
