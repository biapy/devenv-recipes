/**
  # Trivy

  Trivy is a comprehensive and versatile security scanner.
  Trivy has scanners that look for security issues,
  and targets where it can find those issues.

  ## 🛠️ Tech Stack

  - [Trivy homepage](https://trivy.dev/latest/).
  - [Trivy @ GitHub](https://github.com/aquasecurity/trivy).

  ### 🧑‍💻 Visual Studio Code

  - [Aqua Trivy @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=AquaSecurityOfficial.trivy-vulnerability-scanner).
*/
{ pkgs, ... }:
let
  inherit (pkgs) trivy;
in

{
  # https://devenv.sh/packages/
  packages = [ trivy ];

  devcontainer.settings.customizations.vscode.extensions = [
    "AquaSecurityOfficial.trivy-vulnerability-scanner"
  ];
}
