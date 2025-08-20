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
  deadnixCommand = lib.meta.getExe config.git-hooks.hooks.deadnix.package;
in
{
  imports = [ ./nix.nix ];

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.deadnix.enable = true;

  # https://devenv.sh/tasks/
  tasks."ci:lint:nix:deadnix" = {
    description = "Lint *.nix files with deadnix";
    exec = ''
      set -o 'errexit' -o 'pipefail'

      cd "''${DEVENV_ROOT}"
      ${deadnixCommand} --fail"
    '';
  };
}
