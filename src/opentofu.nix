{ config, ... }:

{
  imports = [ ./terraform-common.nix ];

  # https://devenv.sh/languages/
  languages.opentofu.enable = true;

  devcontainer = {
    settings.customizations.vscode.extensions = [ "OpenTofu.vscode-opentofu" ];
  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:format:tf-fmt" =
      let
        inherit (config.languages.opentofu) package;
      in
      {
        description = "Format OpenTofu files";
        exec = ''
          set -o 'errexit'
          ${package}/bin/tofu fmt --recursive
        '';
      };
    "ci:lint:tf-validate" =
      let
        inherit (config.languages.opentofu) package;
      in
      {
        description = "Lint OpenTofu files with tofu validate";
        exec = ''
          set -o 'errexit' -o 'pipefail'
          ${package}/bin/tofu validate --json > "$DEVENV_TASK_OUTPUT_FILE"
        '';
      };
  };
}
