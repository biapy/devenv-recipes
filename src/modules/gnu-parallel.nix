/**
  # GNU Parallel

  ## 🛠️ Tech Stack

  - [GNU Parallel homepage](https://www.gnu.org/software/parallel/).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.biapy-recipes.gnu-parallel;

  parallel = cfg.package;
  parallelCommand = lib.meta.getExe parallel;
in
{
  options.biapy-recipes.gnu-parallel = {
    enable = mkEnableOption "GNU Parallel";
    package = mkPackageOption pkgs "GNU Parallel" { default = "parallel"; };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ parallel ];

    # https://devenv.sh/tasks/
    tasks = {
      "biapy-recipes:enterShell:initialize:parallel" = {
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
  };
}
