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
args@{
  config,
  lib,
  pkgs,
  nixpkgs-unstable,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.lists) map;

  pkgs-unstable = import nixpkgs-unstable { inherit (pkgs.stdenv) system; };
  recipes-lib = import ./lib args;

  imports-args = args // {
    inherit recipes-lib;
    inherit pkgs-unstable;
  };

  taskCfg = config.biapy.go-task;
in
{

  imports = map (path: import path imports-args) [ ./modules ];

  config = {
    biapy.go-task.taskfile.tasks = mkIf taskCfg.prefixed-tasks.enable {
      "ci:lint" = mkDefault {
        aliases = [ "lint" ];
        desc = "🔍 Run all linting tasks";
      };

      "ci:fix" = mkDefault {
        aliases = [ "fix" ];
        desc = "🧹 Run all fixing tasks";
      };

      "ci:format" = mkDefault {
        aliases = [
          "format"
          "fmt"
        ];
        desc = "🎨 Run all formatting tasks";
      };

      "ci:secops" = mkDefault {
        aliases = [ "secops" ];
        desc = "🕵️‍♂️ Run all SecOps tasks";
      };

      "cd:build" = mkDefault {
        aliases = [ "build" ];
        desc = "🔨 Run all building and compiling tasks";
      };

      "cache:clear" = mkDefault {
        aliases = [
          "clear-cache"
          "cc"
        ];
        desc = "🗑️ Run all cache clearing tasks";
      };

      "dev:serve" = mkDefault {
        aliases = [ "serve" ];
        desc = "🚀 Run all development server tasks";
      };
    };

    devcontainer.settings.customizations.vscode.extensions = [ "mkhl.direnv" ];

    scripts = {
      detr = mkDefault {
        description = "Alias of devenv tasks run";
        exec = ''
          cd "''${DEVENV_ROOT}"
          devenv tasks run "''${@}"
        '';
      };

      detl = mkDefault {
        description = "Alias of devenv tasks list";
        exec = ''
          cd "''${DEVENV_ROOT}"
          devenv tasks list "''${@}"
        '';
      };
    };
  };
}
