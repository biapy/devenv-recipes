/**
  # Nix language

  Nix language support.

  ## 🛠️ Tech Stack

  - [Alejandra 💅 @ GitHub](https://github.com/kamadorueda/alejandra).
  - [nixdoc @ GitHub](https://github.com/nix-community/nixdoc).

  ### 🧑‍💻 Visual Studio Code

  - [direnv @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv).

  ## 🙇 Acknowledgements

  - [languages.nix @ Devenv Reference Manual](https://devenv.sh/reference/options/#languagesnixenable).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.biapy.nix;
in
{
  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = with pkgs; [
      alejandra
      nixdoc
    ];

    # https://devenv.sh/languages/
    languages.nix.enable = mkDefault true;

    devcontainer.settings.customizations.vscode.extensions = mkDefault [ "mkhl.direnv" ];
  };
}
