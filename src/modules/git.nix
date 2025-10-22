{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (pkgs) lazygit;

  cfg = config.biapy-recipes.git;

  git = cfg.package;
in
{

  options.biapy-recipes.git = {
    enable = mkEnableOption "Git";
    package = mkPackageOption pkgs "Git" { default = "git"; };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [
      git
      lazygit # Git terminal UI
    ];

    # https://devenv.sh/integrations/difftastic/
    difftastic.enable = true;

    # https://devenv.sh/integrations/delta/
    delta.enable = true;

    enterShell = ''
      git --version
      lazygit --version
    '';

    # https://devenv.sh/tasks/
    tasks = {
      "biapy-recipes:enterTest:git-version" = {
        description = "Test available git command version match devenv git package";
        before = [ "devenv:enterTest" ];
        exec = ''
          set -o 'errexit' -o 'pipefail'
          git --version | grep --color=auto "${git.version}"
        '';
      };
    };
  };
}
