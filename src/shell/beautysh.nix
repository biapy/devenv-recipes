/**
  # beautysh

  `beautysh` is a Bash beautifier for the masses.

  ## 🛠️ Tech Stack

  - [Beautysh @ GitHub](https://github.com/lovesegfault/beautysh).

  ### 📦 Third party tools

  - [fd @ GitHub](https://github.com/sharkdp/fd).

  ## 🙇 Acknowledgements

  - [Setting priorities @ NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-option-definitions-setting-priorities).
  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
  beautysh = config.git-hooks.hooks.beautysh.package;
  beautyshCommand = lib.meta.getExe beautysh;
in
{
  imports = [ ./shell.nix ];

  devcontainer.settings.customizations.vscode = {
    extensions = [ "mkhl.beautysh" ];
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.beautysh.enable = lib.mkDefault false;

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:sh:beautysh" = {
      description = "Lint *.{sh|bash|dash|ksh} files with beautysh";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${fdCommand} '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" \
          --exec ${beautyshCommand} --tab --check
      '';
    };
    "ci:format:sh:beautysh" = {
      description = "Format *.{sh|bash|dash|ksh} files with beautysh";
      exec = ''
        cd "''${DEVENV_ROOT}"
        ${fdCommand} '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" \
          --exec ${beautyshCommand} --tab
      '';
    };
  };
}
