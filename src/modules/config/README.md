# Config Module

Configuration file formatting and linting tools for YAML, JSON, TOML, and XML.

<!-- cSpell:ignore yamllint yamlfmt jsonlint taplo biapy devenv pkgs -->

<!-- cSpell:ignore xmllint xmlstarlet -->

## 🧐 Features

The config module provides four submodules for working with common
configuration file formats:

### YAML

- **yamllint** (Python) - YAML linter for style and syntax checking
- **yamlfmt** (Go) - YAML formatter from Google

### JSON

- **jq** (C) - Command-line JSON processor and formatter
- **jsonlint** (Go) - JSON parser and validator
- **fx** (Go) - Interactive terminal JSON viewer

### TOML

- **taplo** (Rust) - TOML toolkit for formatting and linting

### XML

- **xmllint** (C) - XML validator and formatter from libxml2
- **xmlstarlet** (C) - Command-line XML toolkit

## 📦 Submodules

- `biapy-recipes.config.yaml` - YAML tools
- `biapy-recipes.config.json` - JSON tools
- `biapy-recipes.config.toml` - TOML tools
- `biapy-recipes.config.xml` - XML tools

## 🔨 Tasks

### YAML Tasks

- `ci:lint:yaml:yamllint` - Lint YAML files with yamllint
- `ci:format:yaml:yamlfmt` - Format YAML files with yamlfmt

### JSON Tasks

- `ci:lint:json:jsonlint` - Lint JSON files with jsonlint
- `ci:format:json:jq` - Format JSON files with jq

### TOML Tasks

- `ci:lint:toml:taplo` - Lint TOML files with taplo
- `ci:format:toml:taplo` - Format TOML files with taplo

### XML Tasks

- `ci:lint:xml:xmllint` - Lint XML files with xmllint
- `ci:format:xml:xmllint` - Format XML files with xmllint

## 👷 Commit Hooks

### YAML Hooks

- `yamllint` - Lint YAML files
- `yamlfmt` - Format YAML files

### JSON Hooks

- `check-json` - Check JSON syntax

### TOML Hooks

- `taplo` - Format TOML files

### XML Hooks

- `check-xml` - Check XML syntax

## 🚀 Usage

Enable the submodules you need in your `devenv.nix`:

```nix
{
  biapy-recipes.config = {
    yaml.enable = true;
    json.enable = true;
    toml.enable = true;
    xml.enable = true;
  };
}
```

Or enable individual features:

```nix
{
  biapy-recipes.config.yaml = {
    enable = true;
    tasks = true;
    go-task = true;
    git-hooks = true;
  };
}
```

### Customizing Packages

For modules with multiple tools (YAML, JSON), use the `packages` attribute:

```nix
{
  biapy-recipes.config.json = {
    enable = true;
    packages = {
      jq = pkgs.jq;
      jsonlint = pkgs.jsonlint;
      fx = pkgs.fx;
    };
  };
}
```

For modules where the tool name differs from the module name (TOML), also use
`packages`:

```nix
{
  biapy-recipes.config.toml = {
    enable = true;
    packages.taplo = pkgs.taplo;
  };
}
```

Use `package` (singular) only when the module name matches the tool name:

Use `package` (singular) only when the module name matches the tool name:

```nix
{
  # Example: if there was a module named taplo for taplo tool
  biapy-recipes.taplo = {
    enable = true;
    package = pkgs.taplo; # module name = tool name
  };
}
```

## 🛠️ Tech Stack

- [yamllint @ GitHub](https://github.com/adrienverge/yamllint)
- [yamlfmt @ GitHub](https://github.com/google/yamlfmt)
- [jq @ GitHub](https://github.com/jqlang/jq)
- [jsonlint @ GitHub](https://github.com/prantlf/jsonlint)
- [fx @ GitHub](https://github.com/antonmedv/fx)
- [taplo @ GitHub](https://github.com/tamasfe/taplo)
- [libxml2 @ GitLab](https://gitlab.gnome.org/GNOME/libxml2)
- [xmlstarlet @ SourceForge](https://xmlstar.sourceforge.net/)

## 🙇 Acknowledgements

All tools are written in compiled languages (C, Go, Rust) or Python
for maximum performance.
