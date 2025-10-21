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
  recipes-lib,
  ...
}:
let
  inherit (pkgs) fd;
  inherit (lib.modules) mkIf;
  inherit (recipes-lib.modules) mkToolOptions;

  shellCfg = config.biapy-recipes.shell;
  cfg = shellCfg.shellcheck;

  fdCommand = lib.meta.getExe fd;
  shellcheck = config.git-hooks.hooks.shellcheck.package;
  shellcheckCommand = lib.meta.getExe shellcheck;
in
{
  options.biapy-recipes.shell.shellcheck = mkToolOptions shellCfg "shellcheck";

  config = mkIf cfg.enable {

    packages = [
      fd
      shellcheck
    ];

    devcontainer.settings.customizations.vscode = {
      extensions = [ "timonwong.shellcheck" ];
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks { shellcheck.enable = true; };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:lint:sh:shellcheck" = {
        description = "Lint *.{sh|bash|dash|ksh} files with ShellCheck";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" --exec ${shellcheckCommand}
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:sh:shellcheck" = {
        desc = "Lint shell files with shfmt";
        cmds = [ ''${fdCommand} '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" --exec ${shellcheckCommand}'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
