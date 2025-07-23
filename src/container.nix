{ pkgs, ... }:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    lazydocker # Docker TUI
    ctop # Docker TUI, showing running container resources usage

    hadolint # Dockerfile linter
    dive # Docker image explorer
    container-structure-test # Validate the structure of container images
    trivy # vulnerability scanner for container images
    grype # vulnerability scanner for container images
    syft # Sofware Bill of Materials (SBOM) generator for container images
    trufflehog # Find secrets hidden in the depths of git repositories and container images
    docker-slim # Optimize container images
  ];
}
