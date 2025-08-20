/**
  # devenv scripts

  Scripts to ease devenv use.

  ## 🛠️ Tech Stack

  - [devenv homepage](https://devenv.sh/).
  - [direnv homepage](https://direnv.net/).

  ### Visual Studio Code

  - [direnv @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv).

  ### Third party tools

  - [fd @ GitHub](https://github.com/sharkdp/fd).

  ## 🙇 Acknowledgements

  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
_: {
  devcontainer.settings.customizations.vscode.extensions = [ "mkhl.direnv" ];

  scripts = {
    detr = {
      description = "Alias of devenv tasks run";
      exec = ''
        set -o 'errexit' -o 'nounset' -o 'pipefail'
        cd "''${DEVENV_ROOT}"
        devenv tasks run "''${@}"
      '';
    };
  };
}
