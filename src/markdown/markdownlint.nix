/**
  # markdownlint

  `markdownlint` is a Node.js style checker and lint tool for
  Markdown/CommonMark files.

  ## 🛠️ Tech Stack

  - [markdownlint @ GitHub](https://github.com/DavidAnson/markdownlint).
  - [markdownlint @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{ config, lib, ... }:
let
  markdownlint = config.git-hooks.hooks.markdownlint.package;
  markdownlintCommand = lib.meta.getExe markdownlint;
in
{
  devcontainer.settings.customizations.vscode = {
    extensions = [ "DavidAnson.vscode-markdownlint" ];
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.markdownlint.enable = true;

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:md:markdownlint" = {
      description = "Lint *.md files with markdownlint";
      exec = ''
        set -o 'errexit' -o 'pipefail'
        cd "''${DEVENV_ROOT}"
        ${markdownlintCommand} --json --output "''${DEVENV_TASK_OUTPUT_FILE}"
      '';
    };
  };

}
