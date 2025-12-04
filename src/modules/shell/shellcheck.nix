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
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  shellCfg = config.biapy-recipes.shell;
  cfg = shellCfg.shellcheck;

  fdCommand = lib.meta.getExe fd;
  shellcheck = cfg.package;
  shellcheckCommand = lib.meta.getExe shellcheck;
in
{
  options.biapy-recipes.shell.shellcheck = mkToolOptions shellCfg "shellcheck" // {
    package = mkOption {
      description = "The shellcheck package to use.";
      defaultText = "pkgs.shellcheck";
      type = lib.types.package;
      default = config.git-hooks.hooks.shellcheck.package;
    };
  };

  config = mkIf cfg.enable {
    packages = [
      fd
      shellcheck
    ];

    devcontainer.settings.customizations.vscode = {
      extensions = [ "timonwong.shellcheck" ];
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks { shellcheck.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:sh:shellcheck" = {
        description = "🔍 Lint 🐚shell files with ShellCheck";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" --exec ${shellcheckCommand}
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:sh:shellcheck" = patchGoTask {
        aliases = [ "shellcheck" ];
        desc = "🔍 Lint 🐚shell files with ShellCheck";
        cmds = [ ''fd '\.(sh|bash|dash|ksh)$' --exec shellcheck'' ];
      };
    };
  };
}
