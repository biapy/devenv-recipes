{ pkgs, config, ... }:

{

  # https://devenv.sh/packages/
  packages = with pkgs; [
    tftui
    tfupdate
    tfautomv
    tfmigrate
    tf-summarize
    tfproviderdocs
    inframap
    terraformer
    terraform-docs
    terraform-landscape
    terraform-inventory
    trivy
  ];

  devcontainer = {
    settings.customizations.vscode.extensions = [
      "DerekCAshmore.terraform-docs"
      "ms-azuretools.vscode-azureterraform"
      "AquaSecurityOfficial.trivy-vulnerability-scanner"
    ];
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    terraform-format.enable = true;
    terraform-validate.enable = true;
    tflint.enable = true;

  };

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:tflint" =
      let
        inherit (config.git-hooks.hooks.tflint) package;
      in
      {
        description = "Lint *.tf files with tflint";
        exec = ''
          set -o 'errexit'
          ${package}/bin/tflint '${config.env.DEVENV_ROOT}'
        '';
      };
  };

}
