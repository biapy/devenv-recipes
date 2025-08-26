/**
  # SOPS

  ## 🧐 Features

  ### 🔨 Tasks

  ### 👷 Commit hooks

  - `pre-commit-hook-ensure-sops`: Ensure SOPS encryption for secrets.

  ## 🛠️ Tech Stack

  - [SOPS homepage](https://getsops.io/)
    ([SOPS: Secrets OPerationS @ GitHub](https://github.com/getsops/sops)).
  - [pre-commit-hook-ensure-sops @ GitHub](https://github.com/yuvipanda/pre-commit-hook-ensure-sops).

  ### 🦀 Rust alternatives

  - [ROPS homepage](https://gibbz00.github.io/rops/)
    ([ROPS @ GitHub](https://github.com/gibbz00/rops)).

  ### 🧑‍💻 Visual Studio Code

  - [@signageos/vscode-sops @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=signageos.signageos-vscode-sops).

  ## 🙇 Acknowledgements

  - [Protégez vos secrets DevOps avec SOPS @ DevSecOps :fr:](https://blog.stephane-robert.info/docs/securiser/secrets/sops/).
*/
{ pkgs, ... }:
let
  inherit (pkgs) sops;
in
{
  imports = [ ./age.nix ];

  packages = [
    sops
  ];

  # https://devenv.sh/integrations/codespaces-devcontainer/
  devcontainer.settings.customizations.vscode.extensions = [ "signageos.signageos-vscode-sops" ];

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.pre-commit-hook-ensure-sops.enable = true;
}
