/**
  # Nixdoc

  Nixdoc is a tool to generate documentation from Nix library functions.
  It parses Nix code and generates Markdown or DocBook documentation from
  specially formatted comments.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:nix:nixdoc`: Generate documentation from Nix files with nixdoc.

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

  inherit (pkgs) nixdoc;
  nixdocCommand = lib.meta.getExe nixdoc;
in
{
  options.biapy-recipes.nix.nixdoc = mkToolOptions nixCfg "nixdoc";

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ nixdoc ];

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:nix:nixdoc" = mkDefault {
        description = "📝 Generate documentation from ❄️Nix files with nixdoc";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          cd "''${DEVENV_ROOT}"
          find . -name "*.nix" -type f -not -path "*/.*" -exec ${nixdocCommand} --file {} \; | head -n 0
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:nix:nixdoc" = patchGoTask {
        aliases = [ "nixdoc" ];
        desc = "📝 Generate documentation from ❄️Nix files with nixdoc";
        cmds = [ ''find . -name "*.nix" -type f -not -path "*/.*" -exec nixdoc --file {} \; | head -n 0'' ];
      };
    };
  };
}
