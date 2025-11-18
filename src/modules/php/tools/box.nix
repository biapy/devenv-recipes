/**
  # Box

  `box` is a tool for building and managing Phars (PHP Archives).

  ## 🧐 Features

  ### 🔨 Tasks

  - `cd:build:php:box`: 📦 Build 🐘PHP PHAR with Box.
  - `ci:lint:php:box:info`: 📋 Display PHAR information with Box.
  - `ci:lint:php:box:validate`: 🔍 Validate box.json configuration.

  ## 🛠️ Tech Stack

  - [Box homepage](https://box-project.github.io/box/).
  - [Box @ GitHub](https://github.com/box-project/box).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf;
  inherit (lib.types) package;
  inherit (lib.options) mkOption;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (recipes-lib.modules) mkToolEnableOption mkToolTaskOptions mkToolGoTaskOptions;

  phpToolsCfg = config.biapy-recipes.php.tools;
  cfg = phpToolsCfg.box;

  boxCommand = lib.meta.getExe cfg.package;
in
{
  options.biapy-recipes.php.tools.box = {
    enable = mkToolEnableOption phpToolsCfg "box";
    tasks = mkToolTaskOptions;
    go-task = mkToolGoTaskOptions;

    package = mkOption {
      type = package;
      default = config.languages.php.package.packages.box;
      description = ''
        The Box package to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [ cfg.package ];

    scripts = {
      box = {
        description = "Box - build and manage Phars";
        exec = ''
          ${boxCommand} "''${@}"
        '';
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "cd:build:php:box" = {
        description = "📦 Build 🐘PHP PHAR with Box";
        exec = ''
          cd "''${DEVENV_ROOT}"
          box compile
        '';
      };

      "ci:lint:php:box:info" = {
        description = "📋 Display PHAR information with Box";
        exec = ''
          cd "''${DEVENV_ROOT}"
          box info
        '';
      };

      "ci:lint:php:box:validate" = {
        description = "🔍 Validate box.json configuration";
        exec = ''
          cd "''${DEVENV_ROOT}"
          box validate
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "cd:build:php:box" = patchGoTask {
        aliases = [ "box" ];
        desc = "📦 Build 🐘PHP PHAR with Box";
        cmds = [ "box compile" ];
      };

      "ci:lint:php:box:info" = patchGoTask {
        aliases = [ "box-info" ];
        desc = "📋 Display PHAR information with Box";
        cmds = [ "box info" ];
      };

      "ci:lint:php:box:validate" = patchGoTask {
        aliases = [ "box-validate" ];
        desc = "🔍 Validate box.json configuration";
        cmds = [ "box validate" ];
      };
    };

    # See full reference at https://devenv.sh/reference/options/
  };
}
