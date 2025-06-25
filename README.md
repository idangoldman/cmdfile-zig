# cmdfile

[![CMDFILE Version](https://img.shields.io/badge/cmdfile-0.0.1-green.svg)](https://github.com/idangoldman/cmdfile/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance task runner written in Zig that simplifies development workflows through declarative YAML configuration and intelligent dependency resolution.

## Why cmdfile?

**Performance**: Native compiled binary with zero startup overhead and minimal memory footprint. Built with Zig for maximum efficiency.

**Simplicity**: Clean YAML syntax without the complexity of Makefiles or language-specific DSLs.

**Intelligence**: Automatic dependency resolution with parallel execution and cycle detection.

**Cross-platform**: Native support for Windows, macOS, and Linux with appropriate shell handling.

## Comparison

| Feature | cmdfile | Make | Just | Taskfile |
|---------|---------|------|------|----------|
| Language | Zig | C | Rust | Go |
| Config Format | YAML | Makefile | Justfile | YAML |
| Startup Time | <1ms | <5ms | ~10ms | ~15ms |
| Memory Usage | <2MB | <5MB | ~8MB | ~12MB |
| Dependencies | ✅ | ✅ | ✅ | ✅ |
| File Watching | ✅ | ❌ | ❌ | ✅ |
| Parallel Execution | ✅ | ✅ | ❌ | ✅ |

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
| `dump`.    | Dump the current configuration in YAML format |
| `help`     | Show help message or command help       |
| `init`     | Create an initial cmdfile.yml           |
| `list`     | List all available tasks                |
| `task`     | Execute the specified task              |
| `validate` | Validate the cmdfile.yml configuration  |
| `version`  | Show cmdfile installed version          |

### Flags

| Flag            | Description                                            |
| --------------- | ------------------------------------------------------ |
| `--config-file` | Set `cmdfile.yml` configuration file path              |
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

```yaml
defaults:     # Global settings for all tasks
environment:  # Environment variables
variables:    # Reusable template values
tasks:        # Task definitions with commands and dependencies
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

```yaml
defaults:
  shell: /bin/bash

variables:
  src_dir: src
  build_dir: dist

environment:
  NODE_ENV: development

tasks:
  clean:
    description: "Remove build artifacts"
    command: rm -rf ${build_dir}

  build:
    description: "Build the project"
    command: npm run build
    dependencies: [clean]

  test:
    description: "Run test suite"
    command: npm test
    dependencies: [build]
```

### Complex Rails Application

```yaml
defaults:
  env_file: true
  shell: /bin/bash
  work_dir: .

variables:
  app_name: "myapp"
  rails_env: "development"

environment:
  RAILS_ENV: ${rails_env}
  DATABASE_URL: "postgresql://localhost/${app_name}_${rails_env}"

tasks:
  setup:
    description: "Complete development environment setup"
    dependencies: [install:gems, install:js, db:setup]

  install:
    description: "Install all dependencies"
    sequence: parallel
    dependencies: [install:gems, install:js]

  install:gems:
    description: "Install Ruby dependencies"
    command: bundle install

  install:js:
    description: "Install JavaScript dependencies"
    command: npm install

  db:setup:
    description: "Create and seed database"
    command: rails db:create db:migrate db:seed

  test:
    description: "Run complete test suite"
    dependencies: [test:unit, test:integration]

  test:unit:
    description: "Run unit tests"
    command: rails test:units
    environment:
      RAILS_ENV: test

  test:integration:
    description: "Run integration tests"
    command: rails test:integration
    environment:
      RAILS_ENV: test

  assets:build:
    description: "Compile production assets"
    command: rails assets:precompile
    environment:
      RAILS_ENV: production

  assets:watch:
    description: "Watch and rebuild assets"
    command: rails assets:precompile
    watch:
      - "app/assets/**/*.{scss,js,coffee}"
      - "app/javascript/**/*.{js,ts}"

  setup:mysql:
    description: "Install and configure MySQL"
    command: brew install mysql
    prompts:
      "Install MySQL binary? [y/N]": "y"
      "Start MySQL service now? [y/N]": "y"

  deploy:staging:
    description: "Deploy to staging environment"
    command: cap staging deploy
    dependencies: [test, assets:build]
    confirm: true

  deploy:production:
    description: "Deploy to production environment"
    command: cap production deploy
    dependencies: [test, assets:build]
    confirm: true
    prompts:
      "Deploy to PRODUCTION? This affects live users [y/N]": "y"
    environment:
      RAILS_ENV: production
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
cmdfile validate --config-file test/fixtures/valid.yml
```

## License

MIT License - see [LICENSE](LICENSE) file.
