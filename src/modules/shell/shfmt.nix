/**
  # shfmt

  `shfmt` is a shell parser, formatter, and interpreter.
  It supports POSIX Shell, Bash, and mksh.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:sh:shfmt`: Lint shell files with `shfmt`.
  - `ci:format:sh:shfmt`: Format shell files with `shfmt`.

  ### 👷 Commit hooks

  - `shfmt`: Format shell files with `shfmt`.

  ## 🛠️ Tech Stack

  - [shfmt @ GitHub](https://github.com/mvdan/sh).

  ### 🧑‍💻 Visual Studio Code

  - [shfmt @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=mkhl.shfmt).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.shfmt @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksshfmt).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (recipes-lib.modules) mkToolOptions;

  shellCfg = config.biapy-recipes.shell;
  cfg = shellCfg.shfmt;

  shfmt = config.git-hooks.hooks.shfmt.package;
  shfmtCommand = lib.meta.getExe shfmt;
in
{
  options.biapy-recipes.shell.shfmt = mkToolOptions shellCfg "shfmt";

  config = mkIf cfg.enable {
    packages = [ shfmt ];

    devcontainer.settings.customizations.vscode = {
      extensions = [ "mkhl.shfmt" ];
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks {
      shfmt = {
        enable = true;
        settings.simplify = true;
      };
    };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
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

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:sh:shfmt" = {
        desc = "Lint shell files with shfmt";
        cmds = [ ''shfmt --simplify --diff "''${DEVENV_ROOT}"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };

      "ci:format:sh:shfmt" = {
        aliases = [ "shfmt" ];
        desc = "Format shell files with shfmt";
        cmds = [ ''shfmt --simplify --diff --write "''${DEVENV_ROOT}" || true'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
