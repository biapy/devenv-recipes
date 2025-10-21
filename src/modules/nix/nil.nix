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
  inherit (recipes-lib.modules) mkToolOptions;

  nixCfg = config.biapy-recipes.nix;
  cfg = nixCfg.nil;

  nil = config.git-hooks.hooks.nil.package;
  nilCommand = lib.meta.getExe nil;
  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
in
{
  options.biapy-recipes.nix.nil = mkToolOptions nixCfg "nil";

  config = mkIf cfg.enable {
    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "jnoortheen.nix-ide" ];

    packages = [
      fd
      nil
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks { nil.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {

      "ci:lint:nix:nil" = {
        description = "Lint *.nix files with nil";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.nix$' "''${DEVENV_ROOT}" --exec-batch ${nilCommand} 'diagnostics'
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:lint:nix:nil" = mkDefault {
        aliases = [ "nil" ];
        desc = "Lint *.nix files with nil";
        cmds = [ ''${fdCommand} '\.nix$' "''${DEVENV_ROOT}" --exec-batch ${nilCommand} "diagnostics"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
