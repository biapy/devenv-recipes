/**
  # Biapy devenv recipes

  Recipes and scripts to ease devenv use.

  ## 🧐 Features

  ### 🐚 Commands

  - `detr`: Alias to `devenv tasks run`.

  ## 🛠️ Tech Stack

  - [devenv homepage](https://devenv.sh/).
  - [direnv homepage](https://direnv.net/).

  ### 🧑‍💻 Visual Studio Code

  - [direnv @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv).

  ## 🙇 Acknowledgements

  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{ config, lib, ... }:
let
  inherit (lib.modules) mkIf;

  taskCfg = config.biapy.go-task;
in
{
  imports = [ ./modules ];

  config = {
    biapy.go-task.taskfile.tasks = mkIf taskCfg.prefixed-tasks.enable {
      "ci:lint" = {
        aliases = [ "lint" ];
        desc = "🔍 Run all linting tasks";
      };

      "ci:fix" = {
        aliases = [ "fix" ];
        desc = "🧹 Run all fixing tasks";
      };

      "ci:format" = {
        aliases = [
          "format"
          "fmt"
        ];
        desc = "🎨 Run all formatting tasks";
      };

      "ci:secops" = {
        aliases = [ "secops" ];
        desc = "🕵️‍♂️ Run all SecOps tasks";
      };
    };

    devcontainer.settings.customizations.vscode.extensions = [ "mkhl.direnv" ];

    scripts = {
      detr = {
        description = "Alias of devenv tasks run";
        exec = ''
          cd "''${DEVENV_ROOT}"
          devenv tasks run "''${@}"
        '';
      };

      detl = {
        description = "Alias of devenv tasks list";
        exec = ''
          cd "''${DEVENV_ROOT}"
          devenv tasks list "''${@}"
        '';
      };
    };
  };
}
