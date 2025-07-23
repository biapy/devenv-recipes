{ config, ... }:
let
  working-dir = "${config.env.DEVENV_ROOT}";
in
{
  initializeFile = file: contents: ''
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
