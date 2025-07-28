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
    echo "${contents}" >>"''${file}"
  '';

  gitIgnoreTask =
    {
      name,
      namespace,
      ignoredPaths,
      ...
    }:
    {
      "devenv-recipes:enterShell:initialize:git-ignore:${namespace}" = {
        description = "Update .gitignore for ${name}";
        before = [
          "devenv:enterShell"

        ];
        exec = ''
          set -o 'errexit'

          function initializeGitIgnore() {
            local section_name="''${1}"
            local gitignore="''${DEVENV_ROOT}/.gitignore"

            # Create the .gitignore file if it does not exist
            [[ ! -e "''${gitignore}" ]] && touch "''${gitignore}"

            # Add the devenv-recipes section if it does not exist
            grep --quiet "^###> ''${section_name} ###" ||
            printf "###> %s ###\n###< %s ###" \\
              "''${section_name}" "''${section_name}" \\
              >> "''${gitignore}"
          }

          function updateGitIgnoreSection() {
            local section_name="''${1}"
            local contents="''${2}"
            local gitignore="''${DEVENV_ROOT}/.gitignore"

            # Create the section if it does not exist
            initializeGitIgnore "''${section_name}"

            # Replace contents between the section markers
            sed --in-place --expression="/^###> ''${section_name} ###/,/^###< ''${section_name} ###/c\\
            ''${contents}" "''${gitignore}"
          }

          updateGitIgnoreSection "biapy/devenv-recipes:${namespace}" "${(builtins.concatStringsSep "\n" ignoredPaths)}"
        '';
      };
    };
}
