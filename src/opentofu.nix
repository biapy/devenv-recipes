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
    "ci:format:tf-fmt" = rec {
      description = "Format OpenTofu files";
      exec = "${config.languages.opentofu.package}/bin/tofu fmt -recursive";
    };
    "ci:lint:tf-validate" = {
      description = "Lint OpenTofu files with tofu validate";
      exec = "${config.languages.opentofu.package}/bin/tofu validate";
    };
  };
}
