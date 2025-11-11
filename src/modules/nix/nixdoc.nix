/**
  # Nixdoc

  Nixdoc is a tool to generate documentation from Nix library functions.
  It parses Nix code and generates Markdown or DocBook documentation from
  specially formatted comments.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:docs:nix:nixdoc`: Generate documentation from Nix files with nixdoc.

  ## 🛠️ Tech Stack

  - [nixdoc @ GitHub](https://github.com/nix-community/nixdoc).

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
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.attrsets) optionalAttrs;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  nixCfg = config.biapy-recipes.nix;
  cfg = nixCfg.nixdoc;

  inherit (pkgs) nixdoc fd;
  nixdocCommand = lib.meta.getExe nixdoc;
  fdCommand = lib.meta.getExe fd;
in
{
  options.biapy-recipes.nix.nixdoc = mkToolOptions nixCfg "nixdoc";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [
      nixdoc
      fd
    ];

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:docs:nix:nixdoc" = mkDefault {
        description = "📝 Generate documentation from ❄️Nix files with nixdoc";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          mkdir -p "''${DEVENV_ROOT}/docs/nix"
          ${fdCommand} --type f --extension nix --exec ${nixdocCommand} --file {} \; > "''${DEVENV_ROOT}/docs/nix/library.md"
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:docs:nix:nixdoc" = patchGoTask {
        aliases = [ "nixdoc" ];
        desc = "📝 Generate documentation from ❄️Nix files with nixdoc";
        cmds = [
          "mkdir -p ./docs/nix"
          "fd --type f --extension nix --exec nixdoc --file {} \\; > ./docs/nix/library.md"
        ];
      };
    };
  };
}
