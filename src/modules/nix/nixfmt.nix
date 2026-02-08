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
  - [git-hooks.hooks.nixfmt @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksnixfmt).
  - [treefmt.config.programs.nixfmt @ Devenv Reference Manual](https://devenv.sh/reference/options/#treefmtconfigprogramsnixfmtenable).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (lib.attrsets) optionalAttrs;

  treefmtWrapper = config.git-hooks.hooks.treefmt.package;

  nixCfg = config.biapy-recipes.nix;
  cfg = nixCfg.nixfmt;

  treefmtCommand = "${treefmtWrapper}/bin/treefmt";
in
{
  options.biapy-recipes.nix.nixfmt = mkToolOptions nixCfg "nixfmt";

  config = mkIf cfg.enable {
    devcontainer.settings.customizations.vscode.extensions = mkDefault [ "brettm12345.nixfmt-vscode" ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      nixfmt = {
        enable = mkDefault true;
        args = mkDefault [ "--strict" ];
      };
    };

    treefmt = {
      enable = mkDefault true;

      config.programs.nixfmt = {
        enable = mkDefault true;
        strict = mkDefault true;
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:format:nix:nixfmt" = {
        description = mkDefault "🎨 Format ❄️Nix files with nixfmt";
        exec = mkDefault ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          ${treefmtCommand} --formatters='nixfmt'
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:format:nix:nixfmt" = patchGoTask {
        aliases = mkDefault [
          "nixfmt"
          "format:nix:nixfmt"
          "format:nixfmt"
        ];
        desc = mkDefault "🎨 Format ❄️Nix files with nixfmt";
        cmds = mkDefault [ "treefmt --formatters='nixfmt'" ];
      };
    };
  };
}
