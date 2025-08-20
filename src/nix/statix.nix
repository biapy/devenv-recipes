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
  statixCommand = lib.meta.getExe config.git-hooks.hooks.statix.package;
in
{
  # https://devenv.sh/git-hooks/
  git-hooks.hooks.statix.enable = true;

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:nix:statix" = {
      description = "Lint *.nix files with statix";
      exec = ''
        set -o 'errexit'

        cd "''${DEVENV_ROOT}"
        ${statixCommand} check
      '';
    };
    "ci:format:nix:statix" = {
      description = "Fix *.nix files with statix";
      exec = ''
        set -o 'errexit'

        cd "''${DEVENV_ROOT}"
        ${statixCommand} fix
      '';
    };
  };
}
