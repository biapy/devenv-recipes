/**
  # Functions for PHP tools

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [builtins.attrNames @ Nix 2.28.5 Reference Manual](https://nix.dev/manual/nix/2.28/language/builtins.html#builtins-attrNames).
  - [builtins.map @ Nix 2.28.5 Reference Manual](https://nix.dev/manual/nix/2.28/language/builtins.html#builtins-map).
  - [lib.strings.concatStringsSep @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.concatStringsSep).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.strings) concatStringsSep;
  inherit (lib.lists) map isList;
  inherit (lib.attrsets)
    attrNames
    isAttrs
    optionalAttrs
    mergeAttrsList
    ;
  inherit (recipes-lib.tasks) initializeFile mkGitIgnoreTask initializeFiles;

  cfg = config.biapy-recipes.php;
  toolsPath = cfg.tools.path;

  inherit (config.languages.php.packages) composer;
  composerCommand = lib.meta.getExe composer;
in
rec {
  mkPhpToolTasks =
    toolConfiguration:
    let
      initializeComposerJsonTask = mkInitializeComposerJsonTask toolConfiguration;
      installTask = mkInstallTask toolConfiguration;
      resetTask = mkResetTask toolConfiguration;
      initializeConfigFilesTask = optionalAttrs (isAttrs (toolConfiguration.configFiles or null)) (
        mkInitializeConfigFilesTask toolConfiguration
      );
      gitIgnoreTask = optionalAttrs (isList (toolConfiguration.ignoredPaths or null)) (mkGitIgnoreTask {
        inherit (toolConfiguration) name ignoredPaths;
        namespace = "php:tools:${toolConfiguration.namespace}";
      });
    in
    mergeAttrsList [
      initializeComposerJsonTask
      installTask
      resetTask
      initializeConfigFilesTask
      gitIgnoreTask
    ];

  mkInitializeComposerJsonTask =
    {
      name,
      namespace,
      composerJsonPath,
      ...
    }:
    {
      "biapy-recipes:enterShell:initialize:php:tools:${namespace}:composer-json" =
        let
          toolComposerFile = "${toolsPath}/${namespace}/composer.json";
        in
        {
          description = "Initialize ${name} composer.json";
          before = [ "devenv:enterShell" ];
          status = ''test -e "''${DEVENV_ROOT}/${toolComposerFile}"'';
          exec = initializeFile toolComposerFile composerJsonPath;
        };
    };

  mkInitializeConfigFilesTask =
    {
      name,
      namespace,
      configFiles,
      ...
    }:
    {
      "biapy-recipes:enterShell:initialize:php:tools:${namespace}:configuration" = {
        description = ''Initialize ${name} configuration file(s)'';
        before = [ "devenv:enterShell" ];
        status = ''test ${
          concatStringsSep " -a " (map (file: ''-e "''${DEVENV_ROOT}/${file}"'') (attrNames configFiles))
        }'';
        exec = initializeFiles configFiles;
      };
    };

  mkInstallTask =
    { name, namespace, ... }:
    let
      toolPath = "${toolsPath}/${namespace}";
    in
    {
      "biapy-recipes:enterShell:install:php:tools:${namespace}" = {
        description = "Install ${name}";
        before = [
          "devenv:enterShell"

        ];
        after = [
          "biapy-recipes:enterShell:initialize:php:tools:${namespace}:composer-json"
          "biapy-recipes:enterShell:install:php:composer"
        ];
        status = ''test -e "''${DEVENV_ROOT}/${toolPath}/vendor/autoload.php"'';
        # Use the composer command to install the tool
        exec = ''
          set -o 'errexit'
          '${composerCommand}' --working-dir="''${DEVENV_ROOT}/${toolPath}" 'install'
        '';
      };
    };

  mkResetTask =
    { name, namespace, ... }:
    {
      "reset:php:tools:${namespace}" =
        let
          toolVendorPath = "${toolsPath}/${namespace}/vendor";
        in
        {
          description = "Delete ${name} '${toolVendorPath}' folder";
          exec = ''
            echo "Deleting '''''${DEVENV_ROOT}/${toolVendorPath}' folder"
            [[ -e "''${DEVENV_ROOT}/${toolVendorPath}" ]] &&
              rm -r "''${DEVENV_ROOT}/${toolVendorPath}"
          '';
        };
    };

  mkVendorResetGoTask =
    { name, namespace, ... }:
    {
      "reset:php:tools:${namespace}" =
        let
          toolVendorPath = "${toolsPath}/${namespace}/vendor";
        in
        {
          desc = "Delete ${name} '${toolVendorPath}' folder";
          cmds = [
            ''echo "Deleting '''''${DEVENV_ROOT}/${toolVendorPath}' folder"''
            ''[[ -e "''${DEVENV_ROOT}/${toolVendorPath}" ]] && rm -r "''${DEVENV_ROOT}/${toolVendorPath}"''
          ];
          requires.vars = [ "DEVENV_ROOT" ];
        };
    };
}
