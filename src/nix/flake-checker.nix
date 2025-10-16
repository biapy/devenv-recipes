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
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    mkOption
    types
    ;

  nixCfg = config.biapy.nix;
  cfg = nixCfg.flake-checker;

  # Import flake-checker from nixpkgs-unstable, to get the latest version.
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv) system; };
  inherit (pkgs-unstable) flake-checker;
  flakeCheckerCommand = lib.meta.getExe config.git-hooks.hooks.flake-checker.package;
  inherit (pkgs) glow;
  glowCommand = lib.meta.getExe glow;
in
{
  options.biapy.nix.flake-checker = {
    enable = mkOption {
      type = types.bool;
      description = "Enable flake-checker integration";
      default = false;
    };

    git-hooks = mkOption {
      type = types.bool;
      description = "Enable flake-checker git hooks";
      default = true;
    };

    tasks = mkOption {
      type = types.bool;
      description = "Enable flake-checker devenv tasks";
      default = true;
    };

    go-task = mkOption {
      type = types.bool;
      description = "Enable flake-checker Taskfile tasks";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    packages = [
      flake-checker
      glow
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks {
      flake-checker = {
        enable = true;
        package = flake-checker;
      };
    };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:lint:nix:flake-checker" = {
        description = "Lint Nix flakes with flake-checker";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${flakeCheckerCommand} --no-telemetry --check-outdated --check-owner \
            --check-supported --fail-mode |
            ${glowCommand}
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:nix:flake-checker" = mkDefault {
        aliases = [ "flake-checker" ];
        desc = "Lint Nix flakes with flake-checker";
        cmds = [
          ''
            ${flakeCheckerCommand} --no-telemetry --check-outdated --check-owner --check-supported --fail-mode | ${glowCommand}
          ''
        ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
