{ pkgs, ... }:

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
    "ci:lint:tflint" = {
      description = "Lint *.tf files with tflint";
      exec = "${pkgs.tflint}/bin/tflint";
    };
  };

}
