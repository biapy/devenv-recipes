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
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  # Import flake-checker from nixpkgs-unstable, to get the latest version.
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv) system; };
  inherit (pkgs-unstable) flake-checker;
  flakeCheckerCommand = lib.meta.getExe config.git-hooks.hooks.flake-checker.package;
  inherit (pkgs) glow;
  glowCommand = lib.meta.getExe glow;
in
{
  imports = [ ./nix.nix ];

  packages = [ glow ];

  # https://devenv.sh/tasks/
  tasks."ci:lint:nix:flake-checker" = {
    description = "Link Nix flakes with flake-checker";
    exec = ''
      cd "''${DEVENV_ROOT}"
      ${flakeCheckerCommand} --no-telemetry --check-outdated --check-owner \
        --check-supported --fail-mode |
        ${glowCommand}
    '';
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.flake-checker = {
    enable = true;
    package = flake-checker;
  };
}
