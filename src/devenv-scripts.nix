/**
  # devenv scripts

  Scripts to ease devenv use.

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
_: {
  devcontainer.settings.customizations.vscode.extensions = [ "mkhl.direnv" ];

  scripts = {
    detr = {
      description = "Alias of devenv tasks run";
      exec = ''
        cd "''${DEVENV_ROOT}"
        devenv tasks run "''${@}"
      '';
    };
  };
}
