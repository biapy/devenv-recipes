/**
  # Development Containers

  An open specification for enriching containers with development specific
  content and settings.

  ## 🛠️ Tech Stack

  - [Development Containers homepage](https://containers.dev/)
    ([Development Containers @ GitHub](https://github.com/devcontainers/spec)).
  - [Dev Container CLI @ GitHub](https://github.com/devcontainers/cli).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.biapy-recipes.devcontainer;

  devcontainer = cfg.package;
  devcontainerCommand = lib.meta.getExe devcontainer;
in
{

  options.biapy-recipes.devcontainer = {
    enable = mkEnableOption "devcontainer";
    package = mkPackageOption pkgs "devcontainer" { };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ devcontainer ];

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.enable = mkDefault true;

    # https://devenv.sh/tasks/
    tasks = {
      "dx:devcontainer:build" = mkDefault {
        description = "Build devcontainer";
        exec = ''${devcontainerCommand} build --workspace-folder="''${DEVENV_ROOT}"'';
      };

      "biapy-recipes:enterTest:devcontainer-version" = mkDefault {
        description = "Test available devcontainer command version match devenv devcontainer package";
        before = [ "devenv:enterTest" ];
        exec = ''
          set -o 'errexit' -o 'pipefail'
          devcontainer --version | grep --color=auto "${devcontainer.version}"
        '';
      };
    };
  };
}
