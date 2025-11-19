/**
  # JSON

  JSON formatting and linting tools.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:json:jq`: Lint JSON files with `jq`.
  - `ci:format:json:jq`: Format JSON files with `jq`.

  ### 📦 Packages

  - `jq`: Command-line JSON processor.
  - `fx`: Interactive terminal JSON viewer.

  ### 👷 Commit hooks

  - `check-json`: Check JSON files for syntax errors.

  ## 🛠️ Tech Stack

  - [jq @ GitHub](https://github.com/jqlang/jq) - Command-line JSON processor (C).
  - [fx @ GitHub](https://github.com/antonmedv/fx) - Terminal JSON viewer (Go).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.check-json @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshookscheck-json).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  configCfg = config.biapy-recipes.config;
  cfg = configCfg.json;

  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;

  inherit (cfg.packages) jq fx;

  jqCommand = lib.meta.getExe jq;
in
{
  options.biapy-recipes.config.json = mkToolOptions configCfg "json" // {
    packages = {
      jq = mkOption {
        description = "The jq package to use.";
        defaultText = "pkgs.jq";
        type = lib.types.package;
        default = pkgs.jq;
      };
      fx = mkOption {
        description = "The fx package to use.";
        defaultText = "pkgs.fx";
        type = lib.types.package;
        default = pkgs.fx;
      };
    };
  };

  config = mkIf cfg.enable {
    packages = [
      jq
      fx
      fd
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      check-json = {
        enable = mkDefault true;
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:config:json" = {
        description = "🔍 Lint 🔧JSON files with jq";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.json$' "''${DEVENV_ROOT}" --exec ${jqCommand} empty {}
        '';
      };
      "ci:format:json:jq" = {
        description = "🎨 Format 🔧JSON files with jq";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.json$' "''${DEVENV_ROOT}" --exec-batch sh -c 'for file; do ${jqCommand} --sort-keys . "$file" > "$file.tmp" && mv "$file.tmp" "$file"; done' sh {}
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:config:json" = patchGoTask {
        aliases = [ "jq-lint" ];
        desc = "🔍 Lint 🔧JSON files with jq";
        cmds = [ "fd '\\.json$' --exec jq empty {}" ];
      };

      "ci:format:config:json" = patchGoTask {
        aliases = [ "jq" ];
        desc = "🎨 Format 🔧JSON files with jq";
        cmds = [
          "fd '\\.json$' --exec-batch sh -c 'for file; do jq --sort-keys . \"$file\" > \"$file.tmp\" && mv \"$file.tmp\" \"$file\"; done' sh {}"
        ];
      };
    };
  };
}
