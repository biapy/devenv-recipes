/**
  # Install bamarni/composer-bin-plugin

  ## 🛠️ Tech Stack

  - [Composer bin plugin @ GitHub](https://github.com/bamarni/composer-bin-plugin).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{ config, lib, ... }:
let
  utils = import ../utils { inherit config; };
  composerCommand = lib.meta.getExe config.languages.php.packages.composer;
in
{
  imports = [ ./composer.nix ];

  # https://devenv.sh/tasks/
  tasks =
    {
      "devenv-recipes:enterShell:initialize:composer-bin" = {
        description = "Require 'bamarni/composer-bin-plugin' if missing";
        before = [
          "devenv:enterShell"
          "devenv-recipes:enterShell:install:composer"
        ];
        exec = ''
          set -o 'errexit' -o 'pipefail'

          [[ -e "''${DEVENV_ROOT}/composer.json" ]] || exit 0
          if grep --quiet 'bamarni/composer-bin-plugin' "''${DEVENV_ROOT}/composer.json"; then
            exit 0
          fi

          cd "''${DEVENV_ROOT}"
          ${composerCommand} config --json 'allow-plugins.bamarni/composer-bin-plugin' 'true'
          ${composerCommand} config --json 'extra.bamarni-bin.bin-links' 'false'
          ${composerCommand} require --dev 'bamarni/composer-bin-plugin'
        '';
      };
    }
    // utils.tasks.gitIgnoreTask {
      name = "Composer bin plugin";
      namespace = "composer-bin";
      ignoredPaths = [ "/vendor-bin/**/vendor/" ];
    };
}
