/**
  # XML

  XML formatting and linting tools.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:xml:xmllint`: Lint XML files with `xmllint`.
  - `ci:format:xml:xmllint`: Format XML files with `xmllint`.

  ### 📦 Packages

  - `xmllint`: XML validator and formatter from libxml2.
  - `xmlstarlet`: Command-line XML toolkit.

  ### 👷 Commit hooks

  - `check-xml`: Check XML files for syntax errors.

  ## 🛠️ Tech Stack

  - [libxml2 @ GitLab](https://gitlab.gnome.org/GNOME/libxml2) - XML C parser and toolkit (C).
  - [xmlstarlet @ SourceForge](https://xmlstar.sourceforge.net/) - Command-line XML toolkit (C).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.check-xml @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshookscheck-xml).
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
  cfg = configCfg.xml;

  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;

  inherit (cfg.packages) xmllint xmlstarlet;

  xmllintCommand = lib.meta.getExe xmllint;
in
{
  options.biapy-recipes.config.xml = mkToolOptions configCfg "xml" // {
    packages = {
      xmllint = mkOption {
        description = "The xmllint package to use.";
        defaultText = "pkgs.libxml2";
        type = lib.types.package;
        default = pkgs.libxml2;
      };
      xmlstarlet = mkOption {
        description = "The xmlstarlet package to use.";
        defaultText = "pkgs.xmlstarlet";
        type = lib.types.package;
        default = pkgs.xmlstarlet;
      };
    };
  };

  config = mkIf cfg.enable {
    packages = [
      xmllint
      xmlstarlet
      fd
    ];

    # https://devenv.sh/git-hooks/
    git-hooks.hooks = optionalAttrs cfg.git-hooks {
      check-xml = {
        enable = mkDefault true;
      };
    };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:xml:xmllint" = {
        description = "🔍 Lint 📄XML files with xmllint";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.(xml|xsd|xsl|xslt)$' "''${DEVENV_ROOT}" --exec ${xmllintCommand} --noout {}
        '';
      };
      "ci:format:xml:xmllint" = {
        description = "🎨 Format 📄XML files with xmllint";
        exec = ''
          cd "''${DEVENV_ROOT}"
          ${fdCommand} '\.(xml|xsd|xsl|xslt)$' "''${DEVENV_ROOT}" --exec-batch sh -c 'for file; do ${xmllintCommand} --format "$file" --output "$file"; done' sh {}
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:xml:xmllint" = patchGoTask {
        aliases = [ "xmllint" ];
        desc = "🔍 Lint 📄XML files with xmllint";
        cmds = [ "fd '\\.(xml|xsd|xsl|xslt)$' --exec xmllint --noout {}" ];
      };

      "ci:format:xml:xmllint" = patchGoTask {
        aliases = [ "xmllint-fmt" ];
        desc = "🎨 Format 📄XML files with xmllint";
        cmds = [
          "fd '\\.(xml|xsd|xsl|xslt)$' --exec-batch sh -c 'for file; do xmllint --format \"$file\" --output \"$file\"; done' sh {}"
        ];
      };
    };
  };
}
