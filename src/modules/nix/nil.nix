/**
  # Nil

  Nil is a Nix Language server,
  an incremental analysis assistant for writing in Nix.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:nix:nil`: Lint `.nix` files with `nil`.

  ### 👷 Commit hooks

  - `nil`: Lint `.nix` files `nil`.

  ## 🛠️ Tech Stack

  - [nil @ GitHub](https://github.com/oxalica/nil).

  ### 🧑‍💻 Visual Studio Code

  - [Nix IDE @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=jnoortheen.nix-ide).

  ### 📦 Third party tools

  - [fd @ GitHub](https://github.com/sharkdp/fd).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.nil @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksnil).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
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
  inherit (lib.options) mkOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (lib.attrsets) optionalAttrs;

  nixCfg = config.biapy-recipes.nix;
  cfg = nixCfg.nil;

  nil = cfg.package;
  nilCommand = lib.meta.getExe nil;
  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
in
{
  options.biapy-recipes.nix.nil = mkToolOptions nixCfg "nil" // {
    package = mkOption {
      description = "The nil package to use.";
      defaultText = "config.git-hooks.hooks.nil.package";
      type = lib.types.package;
      default = config.git-hooks.hooks.nil.package;
    };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "jnoortheen.nix-ide" ];

    packages = [
      fd
      nil
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      nil = {
        enable = mkDefault true;
        entry = "${nilCommand} diagnostics";
        args = [ "--deny-warnings" ];
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {

      "ci:lint:nix:nil" = {
        description = "🔍 Lint ❄️Nix files with nil";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.nix$' "''${DEVENV_ROOT}" --exec-batch ${nilCommand} 'diagnostics'
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:nix:nil" = patchGoTask {
        aliases = [ "nil" ];
        desc = "🔍 Lint ❄️Nix files with nil";
        cmds = [ ''fd '\.nix$' --exec-batch nil "diagnostics"'' ];
      };
    };
  };
}
