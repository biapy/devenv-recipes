/**
  # Phpactor

  Phpactor mainly a PHP Language Server with more features than you can shake
  a stick at.

  ## 🧐 Features

  ### 🔨 Tasks

  - `reset:php:phpactor`: Clean Phpactor index for the project.

  ### 🐚 Commands

  - `composer-recipes-install-all`: Install or reinstall all Composer recipes.

  ## 🛠️ Tech Stack

  - [Phpactor @ Read the Docs](https://phpactor.readthedocs.io/en/master/index.html).
  - [Phpactor @ GitHub](https://github.com/phpactor/phpactor).

  ### 🧑‍💻 Visual Studio Code

  - [vscode-phpactor @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=phpactor.vscode-phpactor)
    ([Phpactor VSCode Extension @ GitHub](https://github.com/phpactor/vscode-phpactor)).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [lib.strings.isString @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.isString).
  - [builtins.readFile @ Nix 2.28.5 Reference Manual](https://nix.dev/manual/nix/2.28/language/builtins.html#builtins-readFile).
  - [Operators @ Nix 2.28.5 Reference Manual](https://nix.dev/manual/nix/2.28/language/operators.html).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  php-recipe-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.options) mkPackageOption;
  inherit (lib.modules) mkIf;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (php-recipe-lib) mkInitializeConfigFilesTask;

  phpCfg = config.biapy-recipes.php;
  cfg = phpCfg.phpactor;

  phpactor = cfg.package;
  phpactorCommand = lib.meta.getExe phpactor;
  toolConfiguration = {
    name = "Phpactor";
    namespace = "phpactor";
    configFiles = {
      ".phpactor.yml" = ../../files/php/.phpactor.yml;
    };
  };
in
{
  options.biapy-recipes.php.phpactor = mkToolOptions phpCfg "Phpactor" // {
    package = mkPackageOption pkgs "phpactor" { };
  };

  config = mkIf cfg.enable {
    packages = [ phpactor ];

    languages.php.extensions = [ "mbstring" ];

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "phpactor.vscode-phpactor" ];

    # https://devenv.sh/tasks/
    tasks =
      (mkInitializeConfigFilesTask toolConfiguration)
      // optionalAttrs cfg.tasks {
        "reset:php:phpactor" = {
          description = "🔥 Clean 🐘Phpactor index for the project";
          exec = ''
            echo "Cleaning Phpactor index"
            cd "''${DEVENV_ROOT}"
            ${phpactorCommand} --no-interaction 'index:clean'
          '';
        };
      };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "reset:php:phpactor" = patchGoTask {
        desc = "🔥 Clean 🐘Phpactor index for the project";
        cmds = [
          ''echo "Cleaning Phpactor index"''
          "phpactor --no-interaction 'index:clean'"
        ];
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
