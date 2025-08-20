/**
  # Psalm

  Psalm is a free & open-source static analysis tool that helps you identify
  problems in your code, so you can sleep a little better.

  ## 🛠️ Tech Stack

  - [Psalm homepage](https://psalm.dev/).
  - [Psalm @ GitHub](https://github.com/vimeo/psalm).

  ### PHPStan rules

  ### Visual Studio Code

  - [Psalm (PHP Static Analysis Linting Machine) @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=getpsalm.psalm-vscode-plugin).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.psalm @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshookspsalm).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{ config, lib, ... }:
let
  utils = import ../utils {
    inherit config;
    inherit lib;
  };
  phpCommand = lib.meta.getExe config.languages.php.package;
  composerBinTool = {
    name = "Psalm";
    namespace = "psalm";
    composerJsonPath = ../files/php/vendor-bin/psalm/composer.json;
    configFiles = {
      "psalm.xml.dist" = ../files/php/psalm.xml.dist;
    };
    ignoredPaths = [ "psalm.xml" ];
  };
in
{
  imports = [ ./composer-bin.nix ];

  # https://devenv.sh/integrations/codespaces-devcontainer/
  devcontainer.settings.customizations.vscode.extensions = [ "getpsalm.psalm-vscode-plugin" ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:php:psalm" = {
      description = "Lint '*.php' files with Psalm";
      exec = ''
        set -o 'errexit' -o 'pipefail'

        cd "''${DEVENV_ROOT}"
        ${phpCommand} 'vendor/bin/psalm' --show-info --show-snippet
      '';
    };
  }
  // utils.composer-bin.initializeComposerJsonTask composerBinTool
  // utils.composer-bin.initializeConfigFilesTask composerBinTool
  // utils.composer-bin.installTask composerBinTool
  // utils.tasks.gitIgnoreTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.psalm = {
    enable = true;
    name = "Psalm";
    inherit (config.languages.php) package;
    entry = ''${phpCommand} "''${DEVENV_ROOT}/vendor/bin/psalm"'';
  };

  # See full reference at https://devenv.sh/reference/options/
}
