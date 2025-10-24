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
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  shellCfg = config.biapy-recipes.shell;
  cfg = shellCfg.shfmt;

  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;

  shfmt = cfg.package;
  shfmtCommand = lib.meta.getExe shfmt;
in
{
  options.biapy-recipes.shell.shfmt = mkToolOptions shellCfg "shfmt" // {
    package = mkOption {
      description = "The shfmt package to use.";
      defaultText = "pkgs.shfmt";
      type = lib.types.package;
      default = config.git-hooks.hooks.shfmt.package;
    };
  };

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
      "ci:lint:sh:shfmt" = patchGoTask {
        desc = "🔍 Lint 🐚shell files with shfmt";
        cmds = [ "fd '\.(sh|bash|dash|ksh)$' --exec-batch shfmt --simplify --diff {}" ];
      };

      "ci:format:sh:shfmt" = patchGoTask {
        aliases = [ "shfmt" ];
        desc = "🎨 Format 🐚shell files with shfmt";
        cmds = [ "fd '\.(sh|bash|dash|ksh)$' --exec-batch shfmt --simplify --diff --write {} || true" ];
      };
    };
  };
}
