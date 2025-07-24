{ config, ... }:
let
  working-dir = "${config.env.DEVENV_ROOT}";
in
{
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

    file='${working-dir}/${file}'
    filepath="$(dirname "$file")"

    [[ -e "$file" ]] && exit 0

    mkdir --parent "$filepath" &&
    cp -a "${sourcePath}" "$file"
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

    file='${working-dir}/${file}'
    filepath="$(dirname "$file")"

    [[ -e "$file" ]] && exit 0

    mkdir --parent "$filepath" &&
    tee "$file" << EOF
    ${contents}
    EOF
  '';
}
