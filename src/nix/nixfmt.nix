/**
  # Nixfmt

  Nixfmt is the official formatter for Nix language code.

  ## 🛠️ Tech Stack

  - [Nixfmt @ GitHub](https://github.com/NixOS/nixfmt).
  - [treefmt homepage](https://treefmt.com/latest/)
    ([treefmt @ GitHub](https://github.com/numtide/treefmt)).
  - [nixfmt-tree @ NixPkgs' GitHub](https://github.com/NixOS/nixpkgs/tree/nixos-25.05/pkgs/by-name/ni/nixfmt-tree).

  ### 🧑‍💻 Visual Studio Code

  - [nixfmt @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=brettm12345.nixfmt-vscode).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.nixfmt-rfc-style @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksnixfmt-rfc-style).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    mkOption
    types
    ;

  nixCfg = config.biapy.nix;
  cfg = nixCfg.nixfmt;

  strict-nixfmt-tree = pkgs.nixfmt-tree.override { settings.formatter.nixfmt.options = "--strict"; };
  nixfmtTreeCommand = lib.meta.getExe strict-nixfmt-tree;
in
{
  options.biapy.nix.nixfmt = {
    enable = mkOption {
      type = types.bool;
      description = "Enable Nixfmt integration";
      default = nixCfg.enable;
    };

    git-hooks = mkOption {
      type = types.bool;
      description = "Enable Nixfmt git hooks";
      default = true;
    };

    tasks = mkOption {
      type = types.bool;
      description = "Enable Nixfmt devenv tasks";
      default = true;
    };

    go-task = mkOption {
      type = types.bool;
      description = "Enable Nixfmt Taskfile tasks";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ strict-nixfmt-tree ];

    devcontainer.settings.customizations.vscode.extensions = mkDefault [ "brettm12345.nixfmt-vscode" ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = mkIf cfg.git-hooks {
      nixfmt-rfc-style = {
        enable = mkDefault true;
        args = mkDefault [ "--strict" ];
      };
    };

    # https://devenv.sh/tasks/
    tasks = mkIf cfg.tasks {
      "ci:format:nix:nixfmt" = mkDefault {
        description = "Format *.nix files with nixfmt";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${nixfmtTreeCommand} --tree-root "''${DEVENV_ROOT}"
        '';
      };
    };

    biapy.go-task.taskfile.tasks = mkIf cfg.go-task {
      "ci:format:nix:nixfmt" = mkDefault {
        aliases = [ "nixfmt" ];
        desc = "Format *.nix files with nixfmt";
        cmds = [ ''${nixfmtTreeCommand} --tree-root "''${DEVENV_ROOT}"'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
