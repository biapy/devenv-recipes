/**
  # ShellCheck

  `shellcheck` is a static analysis tool for shell scripts.

  ## 🛠️ Tech Stack

  - [ShellCheck homepage](https://www.shellcheck.net/).
  - [ShellCheck @ GitHub](https://github.com/koalaman/shellcheck).

  ### 🧑‍💻 Visual Studio Code

  - [ShellCheck @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck).

  ### 📦 Third party tools

  - [fd @ GitHub](https://github.com/sharkdp/fd).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
  shellcheck = config.git-hooks.hooks.shellcheck.package;
  shellcheckCommand = lib.meta.getExe shellcheck;
in
{
  imports = [ ./shell.nix ];

  devcontainer.settings.customizations.vscode = {
    extensions = [ "timonwong.shellcheck" ];
  };

  packages = [ fd ];

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.shellcheck.enable = true;

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:sh:shellcheck" = {
      description = "Lint *.{sh|bash|dash|ksh} files with ShellCheck";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${fdCommand} '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" --exec ${shellcheckCommand}
      '';
    };
  };
}
