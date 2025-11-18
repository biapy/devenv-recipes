# devenv-recipes Agents

This document describes the AI agents and automation workflows used in the
devenv-recipes project.

<!-- CSpell:ignore devenv nixpkgs gitleaks statix nixfmt markdownlint mdformat -->

<!-- CSpell:ignore shfmt secops direnv gitmoji Nixpkgs biapy symfony Symfony -->

<!-- CSpell:ignore jsonlint taplo pkgs yamllint yamlfmt semgrep taskfile -->

## 🤖 Overview

The devenv-recipes project uses several automated agents and tools to maintain
code quality, security, and consistency:

## 📋 Pre-commit Hooks

The project uses pre-commit hooks to automatically validate and format code
before commits. These hooks are configured in `.pre-commit-config.yaml` and
managed through devenv.

### Linting Agents

- **cspell**: Spell checker for code and documentation
- **nil**: Nix language server for diagnostics and linting
- **statix**: Static analysis for Nix code
- **markdownlint**: Linter for Markdown files
- **gitleaks**: Detects secrets and credentials in code

### Formatting Agents

- **nixfmt-rfc-style**: Formats Nix code according to RFC style guidelines
- **mdformat**: Formats Markdown files
- **shfmt**: Formats shell scripts

### Security Agents

- **trivy-config**: Configuration file security auditing
- **trivy-fs**: Filesystem security scanning
- **gitleaks**: Secrets detection in git history

### Code Quality

- **flake-checker**: Validates Nix flake configurations

## 🔄 Workflow

1. **Developer makes changes** to Nix modules or documentation
2. **Pre-commit hooks run automatically** on `git commit`
3. **Linters check** for code issues and style violations
4. **Formatters auto-fix** formatting issues
5. **Security scanners** check for vulnerabilities and secrets
6. **Commit proceeds** if all checks pass, or reports errors to fix

## 🛠️ Usage

### Run all hooks manually

```bash
devenv shell -- pre-commit run --all-files
```

### Run specific hook

```bash
devenv shell -- pre-commit run nixfmt-rfc-style --all-files
```

### Skip hooks (not recommended)

```bash
git commit --no-verify
```

## 📚 Task Automation

The project uses [go-task](https://taskfile.dev/) for task automation. Tasks
are organized by category:

- **ci:lint**: Run all linting tasks (alias: `lint`)
- **ci:format**: Run all formatting tasks (alias: `format`, `fmt`)
- **ci:fix**: Run all fixing tasks (alias: `fix`)
- **ci:secops**: Run all security operations (alias: `secops`)
- **cd:build**: Run all build tasks (alias: `build`)
- **cache:clear**: Run all cache clearing tasks (alias: `clear-cache`, `cc`)
- **dev:serve**: Run development servers (alias: `serve`)

### Task Naming Convention

Tasks follow a hierarchical namespace structure using colons (`:`) as separators:

```text
category:action:tool:name
```

**Categories:**

- `ci:` - Continuous Integration tasks (lint, format, fix, secops)
- `cd:` - Continuous Deployment tasks (build, compile)
- `dev:` - Development tasks (serve, watch)
- `cache:` - Cache management tasks (clear)
- `reset:` - Resource cleanup tasks (delete vendor, node_modules)
- `update:` - Update dependencies tasks
- `biapy-recipes:` - Internal framework tasks

**Actions:**

- `lint:` - Linting and validation
- `format:` - Code formatting
- `fix:` - Auto-fixing issues
- `secops:` - Security operations
- `build:` - Building and compiling
- `serve:` - Running development servers
- `clear:` - Clearing caches
- `docs:` - Documentation generation

**Examples:**

- `ci:lint:php:psalm` - Lint PHP files with Psalm
- `ci:format:nix:nixfmt` - Format Nix files with nixfmt
- `cache:clear:php:psalm` - Clear Psalm cache
- `cache:clear:symfony:var` - Clear Symfony var/cache
- `cd:build:php:composer:dump-autoload` - Dump Composer autoload

**Aliases:**

Tasks can have short aliases for convenience:

- Main category tasks: `lint`, `format`, `build`, `cc`
- Tool-specific: `psalm`, `nixfmt`, `shfmt`
- Tool with action: `psalm-cc`, `psalm:cc`

### List available tasks

```bash
task --list-all
```

### Run task category

```bash
task lint      # Run all linting tasks
task format    # Run all formatting tasks
task serve     # Start development servers
task cc        # Clear all caches
```

## 🔧 Configuration

### Adding new hooks

Edit `devenv.nix` to enable additional git hooks:

```nix
git-hooks.hooks = {
  your-hook.enable = true;
};
```

### Adding new tasks

Create tasks in module files under `src/modules/`:

```nix
# devenv tasks
tasks = optionalAttrs cfg.tasks {
  "category:action:tool:name" = {
    description = "Description with emoji";
    exec = "command to run";
  };
};

# go-task
biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
  "category:action:tool:name" = patchGoTask {
    aliases = [ "tool-name" ];
    desc = "Description with emoji";
    cmds = [ "command to run" ];
  };
};
```

## 🤝 Contributing

When contributing to devenv-recipes:

1. **Create a feature branch**: `git checkout -b feat/your-feature-name`
2. Enable devenv shell: `direnv allow`
3. Make your changes incrementally
4. **Commit each logical change** to create a clear history:
   - Use conventional commit format with gitmoji
   - Example: `feat(scope): ✨ description`
   - Commit often to track progress
5. Pre-commit hooks will run automatically on each commit
6. Fix any issues reported by the agents
7. Push your branch and create a pull request

## 📏 Coding Standards

### Clean Code Principles

Follow these clean code best practices:

- **Meaningful names**: Use descriptive variable, function, and module names
- **Single responsibility**: Each function/module should do one thing well
- **DRY (Don't Repeat Yourself)**: Extract common patterns into reusable
  functions
- **KISS (Keep It Simple, Stupid)**: Prefer simple solutions over complex ones
- **Comment when needed**: Explain why, not what (code should be
  self-explanatory)
- **Consistent formatting**: Let nixfmt handle formatting automatically
- **Small functions**: Keep functions focused and concise
- **Avoid magic numbers**: Use named constants instead of hardcoded values

### Nix-Specific Best Practices

- **Use `inherit` for clarity**: Makes code more maintainable
- **Leverage `lib` functions**: Use Nixpkgs library functions instead of
  reinventing
- **Document complex logic**: Add comments for non-obvious Nix expressions
- **Follow RFC 166 style**: Let nixfmt-rfc-style format your code
- **Use `mkDefault`**: Allow downstream overrides of options
- **Validate inputs**: Use assertions and type checking where appropriate

### Module Design

- **Enable by default only when safe**: Most recipes should be
  `enable = false`
- **Provide tasks and go-task**: Support both task systems
- **Use emojis consistently**: Pick meaningful emojis for task descriptions
- **Follow naming conventions**: `category:action:tool:name` for tasks
- **Document options**: Add descriptions to all module options
- **Test your changes**: Verify recipes work in a test project
- **One tool per module**: Each tool gets its own `.nix` file for independence
- **Group by category**: Related tools go in category directories (e.g.,
  `security/`, `config/`)

#### Package Options Naming Convention

Follow this pattern for package customization options:

**Use `package` (singular) when:**

- Module name exactly matches the tool name
- Example: `mdformat.package`, `shfmt.package`

**Use `packages.<tool>` (plural) when:**

- Module name differs from tool name (module represents a concept/language)
- Module has multiple tools
- Examples:
  - `yaml.packages.yamllint` and `yaml.packages.yamlfmt` (module = YAML
    language)
  - `json.packages.jq`, `json.packages.jsonlint`, `json.packages.fx` (module =
    JSON language)
  - `toml.packages.taplo` (module = TOML language, tool = taplo)

```nix
# ✅ Correct: module name matches tool name
options.biapy-recipes.markdown.mdformat = {
  package = mkOption {
    default = pkgs.mdformat;
  };
};

# ✅ Correct: module represents a language/concept
options.biapy-recipes.config.toml = {
  packages.taplo = mkOption {
    default = pkgs.taplo;
  };
};

# ✅ Correct: multiple tools
options.biapy-recipes.config.json = {
  packages = {
    jq = mkOption { default = pkgs.jq; };
    jsonlint = mkOption { default = pkgs.jsonlint; };
    fx = mkOption { default = pkgs.fx; };
  };
};
```

This convention allows:

- Clear distinction between tool-specific and concept-based modules
- Flexibility to add more tools to language/concept modules
- Consistent user experience across the codebase

#### Task Naming for Grouped Modules

When adding tools to category modules (security, secrets, etc.), use the
category in the task path:

**Pattern**: `ci:action:category:tool`

**Examples:**

- `ci:lint:security:semgrep` - Semgrep in security module
- `ci:secops:security:trivy:fs` - Trivy filesystem scan in security module
- `ci:secops:secrets:gitleaks:git` - Gitleaks git scan in secrets module

**Go-task aliases:**

Put aliases inside the task definition with `patchGoTask`:

```nix
biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
  "ci:lint:security:semgrep" = patchGoTask {
    aliases = [ "semgrep" ];
    desc = "🔍 Scan code with semgrep";
    cmds = [ "semgrep scan --config=auto" ];
  };
};
```

### Branch Naming Convention

- `feat/feature-name` - New features
- `fix/bug-name` - Bug fixes
- `docs/topic-name` - Documentation updates
- `refactor/component-name` - Code refactoring
- `test/test-name` - Test additions or updates

### Commit Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/) with
[Gitmoji](https://gitmoji.dev/):

- **Commit frequently**: Each logical change should be a separate commit
- **Write clear messages**: Explain what and why, not just how
- **Use conventional commits**: `type(scope): gitmoji description`
- **Keep changes small**: Smaller commits are easier to review and revert
- **Create history**: Your commit history tells the story of your work

#### Commit Types

- `feat`: ✨ New feature
- `fix`: 🐛 Bug fix
- `docs`: 📝 Documentation changes
- `style`: 🎨 Code style/formatting (no logic change)
- `refactor`: ♻️ Code refactoring
- `perf`: ⚡ Performance improvements
- `test`: ✅ Adding or updating tests
- `chore`: 🔧 Build process or auxiliary tools
- `ci`: 👷 CI/CD changes
- `revert`: ⏪ Revert previous commit

#### Commit Message Format

```text
type(scope): gitmoji short description

Optional longer description explaining what and why.

Optional footer with breaking changes or issue references.
```

Example workflow:

```bash
git checkout -b feat/hugo-recipe
# Make changes to add Hugo module
git add src/modules/go/hugo.nix
git commit -m "feat(go): ✨ add Hugo module structure"

# Add tasks
git add src/modules/go/hugo.nix
git commit -m "feat(go): ➕ add Hugo tasks for build and serve"

# Update documentation
git add src/devenv.nix
git commit -m "feat(go): 🔧 add dev:serve category with serve alias"

# Push branch
git push -u origin feat/hugo-recipe
```

## 📖 References

- [devenv git-hooks documentation](https://devenv.sh/git-hooks/)
- [pre-commit framework](https://pre-commit.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Gitmoji](https://gitmoji.dev/)
