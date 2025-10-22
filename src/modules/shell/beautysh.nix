/**
  # beautysh

  `beautysh` is a Bash beautifier for the masses.

  ⚠️ `beautysh` and `shfmt` don't produce the same output,
  notably with indentation of multi-line pipes.
  Use one or the other to prevent their git hooks from conflicting.

  ## 🛠️ Tech Stack

  - [beautysh @ GitHub](https://github.com/lovesegfault/beautysh).

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
  recipes-lib,
  ...
}:
let
  inherit (pkgs) fd;
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (lib.attrsets) optionalAttrs;

  shellCfg = config.biapy-recipes.shell;
  cfg = shellCfg.beautysh;

  fdCommand = lib.meta.getExe fd;
  beautysh = config.git-hooks.hooks.beautysh.package;
  beautyshCommand = lib.meta.getExe beautysh;
in
{
  options.biapy-recipes.shell.beautysh = mkToolOptions { enable = false; } "beautysh";

  config = mkIf cfg.enable {
    packages = [
      beautysh
      fd
    ];

    devcontainer.settings.customizations.vscode = {
      extensions = [ "mkhl.beautysh" ];
    };

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks { beautysh.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:sh:beautysh" = {
        description = "🔍 Lint 🐚shell files with beautysh";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" \
            --exec ${beautyshCommand} --tab --check
        '';
      };
      "ci:format:sh:beautysh" = {
        description = "🎨 Format 🐚shell files with beautysh";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" \
            --exec ${beautyshCommand} --tab
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:sh:beautysh" = {
        desc = "🔍 Lint 🐚shell files with beautysh";
        cmds = [ ''fd '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" --exec beautysh --tab --check'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };

      "ci:format:sh:beautysh" = {
        aliases = [ "beautysh" ];
        desc = "🎨 Format 🐚shell files with beautysh";
        cmds = [ ''fd '\.(sh|bash|dash|ksh)$' "''${DEVENV_ROOT}" --exec beautysh --tab'' ];
        requires.vars = [ "DEVENV_ROOT" ];
      };
    };
  };
}
