{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;

  cfg = config.biapy-recipes.terraform;
in
{
  config = mkIf cfg.enable {
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
      open-policy-agent # General-purpose policy engine

      # Cost optimization
      infracost

      # IaC Drift detection & Synchronization
      driftctl # Detect, track and alert on infrastructure drift.
      terraformer # CLI tool to generate terraform files from existing infrastructure (reverse Terraform). Infrastructure to Code

      # Visualization & Understanding
      inframap # generate a graph specific for each provider, showing only the resources that are most important/relevant

      # tenv # OpenTofu, Terraform, Terragrunt and Atmos version manager written in Go
      tfproviderdocs # Terraform Provider Documentation Tool
      # tfswitch # A command line tool to switch between different versions of terraform
      # tgswitch # Command line tool to switch between different versions of terragrunt

      # Web apps
      # atlantis # Terraform Pull Request Automation
      # terramate # Adds code generation, stacks, orchestration, change detection, data sharing and more to Terraform
    ];

    devcontainer.settings.customizations.vscode.extensions = [ "ms-azuretools.vscode-azureterraform" ];
  };
}
