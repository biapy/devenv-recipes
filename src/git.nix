{ pkgs, ... }:
let
  inherit (pkgs) git;
in
{
  difftastic.enable = true;
  delta.enable = true;

  # https://devenv.sh/packages/
  packages = [
    git
  ];

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterTest:git-version" = {
      description = "Test available git command version match devenv git package";
      exec = ''
        set -o 'errexit' -o 'pipefail'
        git --version | grep --color=auto "${git.version}"
      '';
      before = [ "devenv:enterTest" ];
    };
  };
}
