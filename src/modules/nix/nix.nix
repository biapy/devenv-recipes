/**
  # Nix language

  Nix language support.

  ## 🧐 Features

  ### 🔨 Tasks

  - `update:nix:flake-update`: Update flake lock files with `devenv update`.

  ## 🛠️ Tech Stack

  - [Alejandra 💅 @ GitHub](https://github.com/kamadorueda/alejandra).
  - [nixdoc @ GitHub](https://github.com/nix-community/nixdoc).

  ### 🧑‍💻 Visual Studio Code

  - [direnv @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv).

  ## 🙇 Acknowledgements

  - [languages.nix @ Devenv Reference Manual](https://devenv.sh/reference/options/#languagesnixenable).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.attrsets) optionalAttrs;
  inherit (recipes-lib.go-tasks) patchGoTask;

  cfg = config.biapy-recipes.nix;
in
{
  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = with pkgs; [
      alejandra
      nixdoc
    ];

    # https://devenv.sh/languages/
    languages.nix.enable = mkDefault true;

    devcontainer.settings.customizations.vscode.extensions = mkDefault [ "mkhl.direnv" ];

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "update:nix:flake-update" = mkDefault {
        description = "⬆️ Update ❄️Nix flake lock files";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          devenv update
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "update:nix:flake-update" = patchGoTask {
        aliases = [ "flake-update" ];
        desc = "⬆️ Update ❄️Nix flake lock files";
        cmds = [ "devenv update" ];
      };
    };
  };
}
