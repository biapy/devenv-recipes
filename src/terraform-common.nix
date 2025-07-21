{ pkgs, config, ... }:

{

  # https://devenv.sh/packages/
  packages = with pkgs; [
    terraform-inventory # Terraform state to ansible inventory adapter
    terraform-landscape # Improve Terraform's plan output to be easier to read and understand
    tf-summarize # Command-line utility to print the summary of the terraform plan
    tfautomv # automate writing moved blocks
    tfmigrate # A Terraform / OpenTofu state migration tool for GitOps

    tftui
    tfupdate

    # Security & compliance
    checkov # Static code analysis tool for infrastructure-as-code
    open-policy-agent # General-purpose policy engine
    terrascan # Detect compliance and security violations across Infrastructure
    trivy # Simple and comprehensive vulnerability scanner for containers, suitable for CI

    # Testing & Verification
    terragrunt # Thin wrapper for Terraform that supports locking for Terraform state and enforces best practices

    # Cost optimization
    infracost

    # IaC Drift detection & Synchronization
    driftctl # Detect, track and alert on infrastructure drift.
    terraformer # CLI tool to generate terraform files from existing infrastructure (reverse Terraform). Infrastructure to Code

    # Visualization & Understanding
    inframap # generate a graph specific for each provider, showing only the resources that are most important/relevant

    # Docs & Workflow management
    atlantis # Terraform Pull Request Automation
    # tenv # OpenTofu, Terraform, Terragrunt and Atmos version manager written in Go
    terraform-docs # Utility to generate documentation from Terraform modules in various output formats
    terramate # Adds code generation, stacks, orchestration, change detection, data sharing and more to Terraform
    tfproviderdocs # Terraform Provider Documentation Tool
    # tfswitch # A command line tool to switch between different versions of terraform
    # tgswitch # Command line tool to switch between different versions of terragrunt
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
