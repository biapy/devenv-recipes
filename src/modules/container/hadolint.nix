/**
  # Haskell Dockerfile Linter

  `hadolint` is a smarter Dockerfile linter that helps building best practice
  Docker images.
  The linter parses the Dockerfile into an AST and performs rules on top of the
  AST.
  It stands on the shoulders of ShellCheck to lint the Bash code inside
  `RUN` instructions.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:container:hadolint`: Lint `Dockerfile` files with `hadolint`.

  ### 👷 Commit hooks

  - `hadolint`: Lint `Dockerfile` files with `hadolint`.

  ## 🛠️ Tech Stack

  - [hadolint @ GitHub](https://github.com/hadolint/hadolint).

  ### 🧑‍💻 Visual Studio Code

  - [hadolint @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=exiasr.hadolint).

  ### 📦 Third party tools

  - [fd @ GitHub](https://github.com/sharkdp/fd).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.hadolint @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshookshadolint).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  containerCfg = config.biapy-recipes.container;
  cfg = containerCfg.hadolint;

  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
  hadolint = cfg.package;
  hadolintCommand = lib.meta.getExe hadolint;
in
{
  options.biapy-recipes.container.hadolint = mkToolOptions { enable = false; } "hadolint" // {
    package = mkOption {
      description = "The hadolint package to use.";
      defaultText = "config.git-hooks.hooks.hadolint.package";
      type = types.package;
      default = config.git-hooks.hooks.hadolint.package;
    };
  };

  config = mkIf cfg.enable {
    packages = [
      fd
      hadolint
    ];

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "exiasr.hadolint" ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks { hadolint.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:container:hadolint" = mkDefault {
        description = "🔍 Lint 🐳Dockerfile files with hadolint";
        exec = ''
          set -o 'errexit'

          cd "''${DEVENV_ROOT}"
          ${fdCommand} 'Dockerfile' --exec ${hadolintCommand} {}
        '';
      };

    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:container:hadolint" = patchGoTask {
        aliases = [ "hadolint" ];
        desc = "🔍 Lint 🐳Dockerfile files with hadolint";
        cmds = [ "fd 'Dockerfile' --exec hadolint {}" ];
      };
    };
  };
}
