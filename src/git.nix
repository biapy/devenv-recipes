{ pkgs, ... }:
let
  inherit (pkgs) git;
in
{
  # https://devenv.sh/packages/
  packages = [
    git
    pkgs.lazygit # Git terminal UI
  ];

  # https://devenv.sh/integrations/difftastic/
  difftastic.enable = true;

  # https://devenv.sh/integrations/delta/
  delta.enable = true;

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterTest:git-version" = {
      description = "Test available git command version match devenv git package";
      before = [ "devenv:enterTest" ];
      exec = ''
        set -o 'errexit' -o 'pipefail'
        git --version | grep --color=auto "${git.version}"
      '';
    };
  };
}
