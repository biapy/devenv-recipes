/**
  # Functions for composer bin tools

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [builtins.attrNames @ Nix 2.28.5 Reference Manual](https://nix.dev/manual/nix/2.28/language/builtins.html#builtins-attrNames).
  - [builtins.map @ Nix 2.28.5 Reference Manual](https://nix.dev/manual/nix/2.28/language/builtins.html#builtins-map).
  - [lib.strings.concatStringsSep @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.concatStringsSep).
*/
{ config, lib, ... }:
let
  tasks = import ./tasks.nix { inherit config; };
  inherit (config.languages.php.packages) composer;
  composerCommand = lib.meta.getExe composer;
in
{

  initializeComposerJsonTask =
    {
      name,
      namespace,
      composerJsonPath,
      ...
    }:
    {
      "devenv-recipes:enterShell:initialize:php:composer-bin:${namespace}:composer-json" = {
        description = "Initialize ${name} composer.json";
        before = [ "devenv:enterShell" ];
        status = ''test -e "''${DEVENV_ROOT}/vendor-bin/${namespace}/composer.json"'';
        exec = tasks.initializeFile "vendor-bin/${namespace}/composer.json" composerJsonPath;
      };
    };

  initializeConfigFilesTask =
    {
      name,
      namespace,
      configFiles,
      ...
    }:
    {
      "devenv-recipes:enterShell:initialize:php:composer-bin:${namespace}:configuration" = {
        description = ''Initialize ${name} configuration file(s)'';
        before = [ "devenv:enterShell" ];
        status = ''test ${
          lib.strings.concatStringsSep " -a " (
            builtins.map (file: ''-e "''${DEVENV_ROOT}/${file}"'') (builtins.attrNames configFiles)
          )
        }'';
        exec = tasks.initializeFiles configFiles;
      };
    };

  installTask =
    { name, namespace, ... }:
    {
      "devenv-recipes:enterShell:install:php:composer-bin:${namespace}" = {
        description = "Install ${name}";
        before = [
          "devenv:enterShell"

        ];
        after = [
          "devenv-recipes:enterShell:initialize:php:composer-bin"
          "devenv-recipes:enterShell:initialize:php:composer-bin:${namespace}:composer-json"
          "devenv-recipes:enterShell:install:php:composer"
        ];
        status = ''test -e "''${DEVENV_ROOT}/vendor-bin/${namespace}/vendor/autoload.php"'';
        # Use the composer command to install the tool
        exec = ''
          set -o 'errexit'
          cd "''${DEVENV_ROOT}"
          '${composerCommand}' 'bin' '${namespace}' 'install'
        '';
      };
    };

  resetTask =
    { name, namespace, ... }:
    {
      "devenv-recipes:reset:php:composer-bin:${namespace}" = {
        description = "Delete ${name} 'vendor-bin/${namespace}/vendor' folder";
        exec = ''
          echo "Deleting '''''${DEVENV_ROOT}/vendor-bin/${namespace}/vendor/' folder"
          [[ -e "''${DEVENV_ROOT}/vendor-bin/${namespace}/vendor/" ]] &&
            rm -r "''${DEVENV_ROOT}/vendor-bin/${namespace}/vendor/"
        '';
      };
    };

}
