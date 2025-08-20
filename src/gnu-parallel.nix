/**
  # GNU Parallel

  ## 🛠️ Tech Stack

  - [GNU Parallel homepage](https://www.gnu.org/software/parallel/).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{ pkgs, lib, ... }:
let
  inherit (pkgs) parallel;
  parallelCommand = lib.meta.getExe parallel;
in
{
  # https://devenv.sh/packages/
  packages = [ parallel ];

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterShell:initialize:parallel" = {
      description = "Accept GNU parallel citation prompt";
      before = [ "devenv:enterShell" ];
      status = ''test -e "''${HOME}/.parallel/will-cite"'';
      exec = ''
        set -o 'errexit'
        yes 'will cite' |
          ${parallelCommand} --citation 2&>'/dev/null'
      '';
    };
  };
}
