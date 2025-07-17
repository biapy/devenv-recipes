{ pkgs, config, ... }:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [ devcontainer ];

  devcontainer.enable = true;

  # https://devenv.sh/tasks/
  tasks = {
    "dx:build-devcontainer" = {
      description = "Build devcontainer";
      exec = "${pkgs.devcontainer}/bin/devcontainer build --workspace-folder='${config.env.DEVENV_ROOT}'";
    };
  };

}
