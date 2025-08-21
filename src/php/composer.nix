/**
  # Composer

  Composer is a dependency manager for PHP,
  allowing to manage libraries and packages in PHP projects.

  ## 🧐 Features

  ### 🔨 Tasks

  - `devenv-recipes:reset:php:composer`: Delete Composer `vendor` folder.

  ### 👷 Commit hooks

  - `composer-validate`: Validate `composer.json` files with `composer validate`.
  - `composer-audit`: Audit `composer.json` files with `composer audit`.

  ## 🛠️ Tech Stack

  - [Composer homepage](https://getcomposer.org/).

  ### 🧑‍💻 Visual Studio Code

  - [Composer @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=DEVSENSE.composer-php-vscode).

  ### Third party tools

  - [GNU Parallel homepage](https://www.gnu.org/software/parallel/).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [Setting priorities @ NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-option-definitions-setting-priorities).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{
  pkgs,
  config,
  lib,
  ...
}:
let
  utils = import ../utils {
    inherit config;
    inherit lib;
  };
  inherit (config.devenv) root;
  inherit (config.languages.php.packages) composer;
  composerCommand = lib.meta.getExe composer;
  inherit (pkgs) parallel;
  parallelCommand = lib.meta.getExe parallel;
in
{
  imports = [
    ../gnu-parallel.nix
    ./php.nix
  ];

  # https://devenv.sh/integrations/codespaces-devcontainer/
  devcontainer.settings.customizations.vscode.extensions = [ "DEVSENSE.composer-php-vscode" ];

  languages.php = {
    enable = true;
    extensions = [
      "curl"
      "filter"
      "iconv"
      "mbstring"
      "openssl"
    ];
  };

  enterShell = ''
    export PATH="${root}/vendor/bin:$PATH"
  '';

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterShell:install:php:composer" = {
      description = "Install composer packages";
      before = [ "devenv:enterShell" ];
      status = ''test -e "''${DEVENV_ROOT}/vendor/autoload.php"'';
      exec = ''
        cd "''${DEVENV_ROOT}"
        [[ -e "''${DEVENV_ROOT}/composer.json" ]] &&
        ${composerCommand} 'install'
      '';
    };

    "devenv-recipes:reset:php:composer" = {
      description = "Delete Composer 'vendor' folder";
      exec = ''
        echo "Deleting Composer 'vendor' folder"
        [[ -e "''${DEVENV_ROOT}/vendor/" ]] &&
          rm -r "''${DEVENV_ROOT}/vendor/"
      '';
    };
  }
  // utils.tasks.gitIgnoreTask {
    name = "Composer";
    namespace = "composer";
    ignoredPaths = [ "/vendor/" ];
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    composer-validate = {
      enable = true;
      name = "composer validate";
      package = composer;
      extraPackages = [ parallel ];
      files = "composer\.(json|lock)$";
      entry = "'${parallelCommand}' '${composerCommand}' 'validate' --no-check-publish {} ::: ";
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };

    composer-audit = {
      enable = true;
      name = "composer audit";
      after = [ "composer-validate" ];
      package = composer;
      files = "composer\.(json|lock)$";
      pass_filenames = false;
      entry = "'${composerCommand}' 'audit'";
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
