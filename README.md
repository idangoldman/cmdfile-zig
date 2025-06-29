# cmdfile

[![CMDFILE Version](https://img.shields.io/badge/cmdfile-0.0.1-green.svg)](https://github.com/idangoldman/cmdfile/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance task runner written in Zig that simplifies development workflows through declarative TOML configuration and intelligent dependency resolution.

## Why cmdfile?

**Performance**: Native compiled binary with zero startup overhead and minimal memory footprint. Built with Zig for maximum efficiency.

**Simplicity**: Clean TOML syntax without the complexity of Makefiles or language-specific DSLs.

**Intelligence**: Automatic dependency resolution with parallel execution and cycle detection.

**Cross-platform**: Native support for Windows, macOS, and Linux with appropriate shell handling.

## Comparison

| Feature | cmdfile | Make | Just | Taskfile |
|---------|---------|------|------|----------|
| Language | Zig | C | Rust | Go |
| Config Format | TOML | Makefile | Justfile | YAML |
| Cross-platform | ✅ | ✅ | ✅ | ✅ |
| Dependencies | ✅ | ✅ | ✅ | ✅ |
| Environment Variables | ✅ | ✅ | ✅ | ✅ |
| Error Handling | ✅ | ❌ | ❌ | ✅ |
| File Watching | ✅ | ❌ | ❌ | ✅ |
| Interactive Prompts | ✅ | ❌ | ❌ | ✅ |
| Parallel Execution | ✅ | ✅ | ❌ | ✅ |
| Sequence Control | ✅ | ❌ | ❌ | ✅ |
| Shell Support | ✅ | ✅ | ✅ | ✅ |
| Task Validation | ✅ | ❌ | ❌ | ✅ |
| Variable Substitution | ✅ | ❌ | ✅ | ✅ |

## Installation

```shell
# From releases
curl -L https://github.com/username/cmdfile/releases/latest/download/cmdfile -o cmdfile
chmod +x cmdfile && mv cmdfile ~/.local/bin

# From source
git clone https://github.com/username/cmdfile.git && cd cmdfile
zig build -Doptimize=ReleaseFast
cp zig-out/bin/cmdfile /usr/local/bin/
```

## Quick Start

```shell
# Initialize configuration
cmdfile init

# List available tasks
cmdfile list

# Show execution plan without running
cmdfile task start --dry-run

# Execute a task
cmdfile task start
```

## CLI Interface

### Usage

```shell
cmdfile <command> [task_name] [--flag[=value]...] [variable=value...] [ENVIRONMENT=value...]
```

### Commands

| Command    | Description                             |
| ---------- | --------------------------------------- |
| `dump`     | Dump the current configuration in TOML format |
| `help`     | Show help message or command help       |
| `init`     | Create an initial cmdfile.toml           |
| `list`     | List all available tasks                |
| `task`     | Execute the specified task              |
| `validate` | Validate the cmdfile.toml configuration  |
| `version`  | Show cmdfile installed version          |

### Flags

| Flag            | Description                                            |
| --------------- | ------------------------------------------------------ |
| `--config-file` | Set `cmdfile.toml` configuration file path              |
| `--dry-run`     | Show execution plan without running commands           |
| `--env-file`    | Load environment variables from specified .env file    |
| `--sudo`        | Run commands with administrative permissions           |
| `--verbose`     | Show detailed logs (info, warning, error, debug)      |
| `--work-dir`    | Set working directory for task execution              |
| `--shell`       | Override default shell for command execution           |
| `--no-color`    | Disable colored output in logs                         |
| `--no-confirm`  | Skip user confirmation prompts before executing tasks |

## Configuration File

### File Structure

```toml
[defaults]     # Global settings for all tasks
[environment]  # Environment variables
[variables]    # Reusable template values
[tasks]        # Task definitions with commands and dependencies
```

### Defaults Section

| Parameter  | Type    | Default     | Description                     |
| ---------- | ------- | ----------- | ------------------------------- |
| `env_file` | boolean | `false`     | Load environment from .env file |
| `shell`    | string  | `/bin/bash` | Shell for command execution     |
| `work_dir` | string  | `.`         | Base directory for tasks        |

### Variables Section

| Parameter | Type   | Description                             |
| --------- | ------ | --------------------------------------- |
| `<name>`  | string | Reusable value accessible via `${name}` |

### Environment Section

| Parameter    | Type   | Description                             |
| ------------ | ------ | --------------------------------------- |
| `<VAR_NAME>` | string | Environment variable for task execution |

### Tasks Section

| Parameter      | Type    | Required | Description                         |
| -------------- | ------- | -------- | ----------------------------------- |
| `command`      | string  | Yes      | Shell command to execute            |
| `confirm`      | boolean | No       | Require user confirmation           |
| `dependencies` | array   | No       | Tasks that must complete first      |
| `description`  | string  | No       | Human-readable task description     |
| `environment`  | object  | No       | Task-specific environment variables |
| `prompts`      | object  | No       | Automated responses to interactive prompts during task execution |
| `shell`        | string  | No       | Override default shell              |
| `variables`    | object  | No       | Task-specific template variables    |
| `watch`        | array   | No       | File patterns to monitor for changes |
| `work_dir`     | string  | No       | Override default working directory  |

## Features

### Dependency Resolution

Tasks automatically execute in correct order based on dependencies. Independent tasks run in parallel to minimize execution time. Circular dependencies are detected and reported as errors.

### File Watching

The `watch` parameter monitors file patterns and re-executes tasks when changes occur. Supports glob patterns and multiple file types.

### Interactive Task Handling

The `prompts` parameter provides automated responses to interactive questions that commands may ask during execution. The `confirm` parameter requires user confirmation before starting the task.

### Variable Substitution

Use `${variable_name}` syntax to reference values from the variables section or environment variables.

### Error Handling

Comprehensive validation with clear error messages for configuration issues, missing dependencies, and execution failures.

## Example Configuration

### Simple Project

```toml
[defaults]
shell = "/bin/bash"

[variables]
src_dir = "src"
build_dir = "dist"

[environment]
NODE_ENV = "development"

[tasks.clean]
description = "Remove build artifacts"
command = "rm -rf ${build_dir}"

[tasks.build]
description = "Build the project"
command = "npm run build"
dependencies = ["clean"]
watch = ["${src_dir}/**/*.{js,ts,css}"]

[tasks.install]
description = "Install project dependencies"
command = "npm install"
dependencies = ["clean"]

[tasks.test]
description = "Run test suite"
command = "npm test"
dependencies = ["build"]
```

### Complex Rails Application

```toml
[defaults]
env_file = true
shell = "/bin/bash"
work_dir = "."

[variables]
app_name = "myapp"
rails_env = "development"

[environment]
RAILS_ENV = "${rails_env}"
DATABASE_URL = "postgresql://localhost/${app_name}_${rails_env}"

[tasks.setup]
description = "Complete development environment setup"
dependencies = ["install.gems", "install.js", "db.setup"]

[tasks.install]
description = "Install all dependencies"
sequence = "parallel"
dependencies = ["install.gems", "install.js"]

[tasks.install.gems]
description = "Install Ruby dependencies"
command = "bundle install"

[tasks.install.js]
description = "Install JavaScript dependencies"
command = "npm install"

[tasks.db.setup]
description = "Create and seed database"
command = "rails db:create db:migrate db:seed"

[tasks.test]
description = "Run complete test suite"
dependencies = ["test.unit", "test.integration"]

[tasks.test.unit]
description = "Run unit tests"
command = "rails test:units"
environment = { RAILS_ENV = "test" }

[tasks.test.integration]
description = "Run integration tests"
command = "rails test:integration"
environment = { RAILS_ENV = "test" }

[tasks.assets.build]
description = "Compile production assets"
command = "rails assets:precompile"

[tasks.assets.build.environment]
RAILS_ENV = "production"

[tasks.assets.watch]
description = "Watch and rebuild assets"
command = "rails assets:precompile"
watch = [
  "app/assets/**/*.{scss,js,coffee}",
  "app/javascript/**/*.{js,ts}"
]

[tasks.setup.mysql]
description = "Install and configure MySQL"
command = "brew install mysql"

[tasks.setup.mysql.prompts]
"Install MySQL binary? [y/N]" = "y"
"Start MySQL service now? [y/N]" = "y"

[tasks.deploy.staging]
description = "Deploy to staging environment"
command = "cap staging deploy"
dependencies = ["test", "assets.build"]
confirm = true

[tasks.deploy.production]
description = "Deploy to production environment"
command = "cap production deploy"
dependencies = ["test", "assets.build"]
confirm = true

[tasks.deploy.production.prompts]
"Deploy to PRODUCTION? This affects live users [y/N]" = "y"

[tasks.deploy.production.environment]
RAILS_ENV = "production"
```

## Contributing

### Development Setup

```bash
git clone https://github.com/username/cmdfile.git
cd cmdfile

# Install Zig 0.14.1+
# Build and test
zig build
zig build test

# Run integration tests
./test/integration.sh
```

### Code Standards

- Follow Zig formatting: `zig fmt src/`
- Add tests for new features
- Update documentation for API changes
- Ensure cross-platform compatibility

### Testing

```bash
# Run all tests
zig build test

# Run specific test suites
zig test test/config_test.zig
zig test test/task_runner_test.zig

# Test configuration validation
cmdfile validate --config-file test/fixtures/valid.toml
```

## License

MIT License - see [LICENSE](LICENSE) file.

## TODOs

- migration from other task/command/script runner config files.
- templates for various language, framework, development environment, etc setups.
- migration from YAML to TOML config file based on.
- tab completion
- `tasks.tests` will execute tasks grouped in sequence and order they are in the config file
- sequence option values: serial, parallel, pipe, and, semi.
- features: configuration format, dependencies sequence,variables and environment variables, command execution errors, help documentation, cross platform shell execution, task validation, file watching.
