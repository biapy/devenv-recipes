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
{ pkgs, lib, ... }:
let
  inherit (pkgs) devcontainer;
  devcontainerCommand = lib.meta.getExe devcontainer;
in
{
  # https://devenv.sh/packages/
  packages = [ devcontainer ];

  # https://devenv.sh/integrations/codespaces-devcontainer/
  devcontainer.enable = true;

  # https://devenv.sh/tasks/
  tasks = {
    "dx:build-devcontainer" = {
      description = "Build devcontainer";
      exec = ''${devcontainerCommand} build --workspace-folder="''${DEVENV_ROOT}"'';
    };
  };

}
