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
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (lib.attrsets) optionalAttrs;

  shellCfg = config.biapy-recipes.shell;
  cfg = shellCfg.shfmt;

  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;

  shfmt = config.git-hooks.hooks.shfmt.package;
  shfmtCommand = lib.meta.getExe shfmt;
in
{
  options.biapy-recipes.shell.shfmt = mkToolOptions shellCfg "shfmt";

  config = mkIf cfg.enable {
    packages = [
      shfmt
      fd
    ];

    devcontainer.settings.customizations.vscode = {
      extensions = [ "mkhl.shfmt" ];
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      shfmt = {
        enable = mkDefault true;
        settings.simplify = mkDefault true;
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:sh:shfmt" = {
        description = "🔍 Lint 🐚shell files with shfmt";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" --exec-batch ${shfmtCommand} --simplify --diff {}
        '';
      };
      "ci:format:sh:shfmt" = {
        description = "🎨 Format 🐚shell files with shfmt";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" --exec-batch ${shfmtCommand} --simplify --diff --write {} || true
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:sh:shfmt" = {
        desc = "🔍 Lint 🐚shell files with shfmt";
        cmds = [
          ''fd '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" --exec-batch shfmt --simplify --diff {}''
        ];
        requires.vars = [ "DEVENV_ROOT" ];
      };

      "ci:format:sh:shfmt" = {
        aliases = [ "shfmt" ];
        desc = "🎨 Format 🐚shell files with shfmt";
        cmds = [
          ''fd '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" --exec-batch shfmt --simplify --diff --write {} || true''
        ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
