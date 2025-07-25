_: {
  /**
    Create the contents of a bash script that:

    For each `${file}` = `{$sourcePath}` pair in `${configFiles}` attribute set:

    1. Check if `${DEVENV_ROOT}/${file}` exists,
    2. copy `${sourcePath}` to `${DEVENV_ROOT}/${file}` if not.

    It's helpful for creating example configuration files.

    # Example

    ```nix
    _: let
      utils = import ../utils { inherit config; };
    in {
      tasks.initializeConfiguration.exec =
        utils.tasks.initializeFile { "vendor-bin/phpmd/composer.json" = ./phpmd-composer.json; };
    }
    ```

    # Type

    ```
    initializeFile :: Attrset {String = Path;} -> String
    ```

    # Arguments

    configFiles
    : a set of file paths and their source paths `{String = Path;}`, where:

      - the key is the initialized file path in the devenv.
      - the value is the source path in the local nix package.
  */
  initializeFiles = configFiles: ''
    set -o 'errexit'

    function initializeFile() {
      local file="''${1}"
      local sourcePath="''${2}"

      file="''${DEVENV_ROOT}/''${file}"
      filepath="$(dirname "''${file}")"

      [[ -e "''${file}" ]] && return 0

      mkdir --parent "''${filepath}" &&
      cp "''${sourcePath}" "''${file}"
    }

    ${
      (builtins.concatStringsSep "\n" (
        builtins.attrValues (
          builtins.mapAttrs (file: sourcePath: ''initializeFile "${file}" "${sourcePath}"'') configFiles
        )
      ))
    }
  '';

  /**
    Create the contents of a bash script that:

    1. Check if `${DEVENV_ROOT}/${file}` exists,
    2. copy `${sourcePath}` to `${DEVENV_ROOT}/${file}` if not.

    It's helpful for creating example configuration files.

    # Example

    ```nix
    _: let
      utils = import ../utils { inherit config; };
    in {
      tasks.initializeConfiguration.exec =
        utils.tasks.initializeFile "vendor-bin/phpmd/composer.json" ./phpmd-composer.json;
    }
    ```

    # Type

    ```
    initializeFile :: String -> Path -> String
    ```

    # Arguments

    file
    : the initialized file path in the devenv.

    sourcePath
    : the source path in the local nix package.
  */
  initializeFile = file: sourcePath: ''
    set -o 'errexit'

    file="''${DEVENV_ROOT}/${file}"
    filepath="$(dirname "''${file}")"

    [[ -e "''${file}" ]] && exit 0

    mkdir --parent "''${filepath}" &&
      cp "${sourcePath}" "''${file}"
  '';

  /**
    Create the contents of a bash script that:

    1. Check if `${DEVENV_ROOT}/${file}` exists,
    2. write `${contents}` to `${DEVENV_ROOT}/${file}` if not.

    It's helpful for creating example configuration files.

    # Example

    ```nix
    _: let
      utils = import ../utils { inherit config; };
    in {
      tasks.initializeConfiguration.exec =
        utils.tasks.initializeFileContents "vendor-bin/phpmd/composer.json" ''
          {
            "require-dev": {
              "phpmd/phpmd": "@stable"
            }
          }
        '';
    }
    ```

    # Type

    ```
    initializeFileContents :: String -> String -> String
    ```

    # Arguments

    file
    : the initialized file path in the devenv.

    contents
    : the contents to initialize the file with.
  */
  initializeFileContents = file: contents: ''
    set -o 'errexit'

    file="''${DEVENV_ROOT}/${file}"
    filepath="$(dirname "''${file}")"

    [[ -e "''${file}" ]] && exit 0

    mkdir --parent "''${filepath}" &&
    tee "''${file}" << EOF
    ${contents}
    EOF
  '';
}
