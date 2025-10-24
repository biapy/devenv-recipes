/**
  # Nix flakes

  Nix Flake Checker is a tool from [Determinate Systems](https://determinate.systems/)
  that performs "health" checks on the `flake.lock` files in flake-powered Nix
  projects.
  Its aims to help Nix projects stay on recent and supported versions of
  [Nixpkgs](https://github.com/NixOS/nixpkgs).

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:nix:flake-checker`: Lint Nix flakes with `flake-checker`.

  ### 👷 Commit hooks

  - `flake-checker`: Lint `flake.lock` file `flake-checker`.

  ## 🛠️ Tech Stack

  - [Nix Flake Checker @ GitHub](https://github.com/DeterminateSystems/flake-checker).
  - [DeterminateSystems/flake-checker @ FlakeHub](https://flakehub.com/flake/DeterminateSystems/flake-checker).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.flake-checker @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksflake-checker).
*/
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  nixCfg = config.biapy-recipes.nix;
  cfg = nixCfg.flake-checker;

  # Import flake-checker from nixpkgs-unstable, to get the latest version.
  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
  inherit (pkgs-unstable) flake-checker;
  flakeCheckerCommand = lib.meta.getExe config.git-hooks.hooks.flake-checker.package;
  inherit (pkgs) glow;
  glowCommand = lib.meta.getExe glow;
in
{
  options.biapy-recipes.nix.flake-checker = mkToolOptions nixCfg "flake-checker";

  config = mkIf cfg.enable {
    packages = [
      fd
      flake-checker
      glow
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      flake-checker = {
        enable = mkDefault true;
        package = flake-checker;
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:nix:flake-checker" = {
        description = "🔍 Lint ❄️Nix flakes with flake-checker";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '^flake\.lock$' --exec ${flakeCheckerCommand} --no-telemetry --check-outdated --check-owner \
            --check-supported --fail-mode {} |
            ${glowCommand}
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:nix:flake-checker" = patchGoTask {
        aliases = [ "flake-checker" ];
        desc = "🔍 Lint ❄️Nix flakes with flake-checker";
        cmds = [
          "fd '^flake\\.lock$' --exec flake-checker --no-telemetry --check-outdated --check-owner --check-supported --fail-mode | glow"
        ];
      };
    };
  };
}
