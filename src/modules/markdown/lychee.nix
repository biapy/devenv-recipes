/**
  # Lychee

  Lychee is fast, async, stream-based link checker written in Rust.
  It finds broken URLs and mail addresses inside Markdown, HTML,
  reStructuredText, websites, …

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:md:lychee`: Lint Markdown files internal links with `lychee`.
  - `tests:md:lychee`: Lint Markdown files URLs with `lychee`.

  ### 👷 Commit hooks

  - `lychee`: Lint Markdown files URLs with `lychee`.

  ## 🛠️ Tech Stack

  - [Lychee homepage](https://lychee.cli.rs//)
    ([Lychee @ GitHub](https://github.com/lycheeverse/lychee)).

  ## 🙇 Acknowledgements

  - [git-hooks.hooks.lychee @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshookslychee).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;

  mdCfg = config.biapy-recipes.markdown;
  cfg = mdCfg.lychee;

  lychee = cfg.package;
  lycheeCommand = lib.meta.getExe lychee;
in
{
  options.biapy-recipes.markdown.lychee = mkToolOptions { enable = false; } "lychee" // {
    package = mkOption {
      description = "The lychee package to use.";
      defaultText = "config.git-hooks.hooks.lychee.package";
      type = types.package;
      default = config.git-hooks.hooks.lychee.package;
    };
  };

  config = mkIf cfg.enable {
    packages = [ lychee ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      lychee = {
        enable = mkDefault true;
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:md:lychee" = {
        description = "🔍 Lint 📝Markdown files 🔗internal links with lychee";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${lycheeCommand} --offline --no-progress "''${DEVENV_ROOT}/**/*.md"
        '';
      };

      "tests:md:lychee" = {
        description = "🧪 test 📝Markdown files 🔗URLs with lychee";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${lycheeCommand} --no-progress "''${DEVENV_ROOT}/**/*.md"
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:md:lychee" = patchGoTask {
        aliases = [ "lychee" ];
        desc = "🔍 Lint 📝Markdown files 🔗internal links with lychee";
        cmds = [ "lychee --offline --no-progress '**/*.md'" ];
      };

      "tests:md:lychee" = patchGoTask {
        desc = "🧪 test 📝Markdown files 🔗URLs with lychee";
        cmds = [ "lychee --no-progress '**/*.md'" ];
      };
    };
  };
}
