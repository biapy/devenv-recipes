{ pkgs, ... }:
let
  inherit (pkgs) parallel;
in
{
  # https://devenv.sh/packages/
  packages = [ parallel ];

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterShell:configure:parallel" = {
      description = "Accept GNU parallel citation prompt";
      before = [ "devenv:enterShell" ];
      exec = ''
        set -o 'errexit'
        yes 'will cite' |
          ${parallel}/bin/parallel --citation 2&>'/dev/null'
      '';
    };
  };
}
