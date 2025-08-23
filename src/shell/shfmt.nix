/**
  # shfmt

  `shfmt` is a shell parser, formatter, and interpreter.
  It supports POSIX Shell, Bash, and mksh.

  ## 🛠️ Tech Stack

  - [shfmt @ GitHub](https://github.com/mvdan/sh).

  ### 🧑‍💻 Visual Studio Code

  - [shfmt @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=mkhl.shfmt).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.shfmt @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksshfmt).
*/
{ config, lib, ... }:
let
  shfmt = config.git-hooks.hooks.shfmt.package;
  shfmtCommand = lib.meta.getExe shfmt;
in
{
  imports = [ ./shell.nix ];

  devcontainer.settings.customizations.vscode = {
    extensions = [ "mkhl.shfmt" ];
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.shfmt = {
    enable = true;
    settings.simplify = true;
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:sh:shfmt" = {
      description = "Lint shell files with shfmt";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${shfmtCommand} --simplify --diff "''${DEVENV_ROOT}"
      '';
    };
    "ci:format:sh:shfmt" = {
      description = "Format shell files with shfmt";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${shfmtCommand} --simplify --diff --write "''${DEVENV_ROOT}" || true
      '';
    };
  };
}
