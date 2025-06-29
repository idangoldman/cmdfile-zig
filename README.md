# cmdfile

[![CMDFILE Version](https://img.shields.io/badge/cmdfile-0.1.0-green.svg)](https://github.com/idangoldman/cmdfile/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance task runner written in Zig that simplifies development workflows through declarative TOML configuration and intelligent task management. `cmdfile` is designed to be a lightweight, efficient, and user-friendly alternative to traditional task runners like Make, Just, and Taskfile.

## Why cmdfile?

**Cross-platform**: Native support for Windows, macOS, and Linux with appropriate shell handling.
**Extensible**: Easily extendable with custom commands and plugins.
**Intelligence**: Automatic dependency resolution with parallel execution and cycle detection.
**Interactive**: Supports interactive prompts and confirmations for critical tasks.
**Performance**: Native compiled binary with zero startup overhead and minimal memory footprint. Built with Zig for maximum efficiency and safety as self-contained executable with no runtime dependencies.
**Simplicity**: Clean TOML syntax without the complexity of Makefiles or language-specific DSLs.
**Testing**: Built-in testing framework for validating task configurations and execution.

### Features

- **Declarative Configuration**: Define tasks, dependencies, and environment variables in a simple TOML file.
- **Environment Variables**: Supports environment variable management for tasks.
- **Error Handling**: Comprehensive error handling with clear messages for configuration issues and execution failures.
- **File Watching**: Monitors file changes and re-executes tasks automatically.
- **Interactive Prompts**: Handles interactive prompts and confirmations for tasks that require user input.
- **Parallel Execution**: Runs independent tasks in parallel to speed up execution.
- **Shell Support**: Executes commands in the user's preferred shell with cross-platform compatibility.
- **Task Dependencies**: Automatically resolves task dependencies and executes them in the correct order.
- **Testing Framework**: Built-in testing framework for validating task configurations and execution.
- **Variable Substitution**: Supports variable substitution in commands using `${variable_name}` syntax.

### Alternatives

- **Cargo**: Rust package manager and build system, but limited to Rust projects and lacks cross-language support.
- **Composer**: PHP package manager with build capabilities, but limited to PHP projects and lacks cross-language support.
- **Grunt**: JavaScript task runner with a focus on configuration over code, but can be verbose and less performant than `cmdfile`.
- **Gulp**: JavaScript task runner with a focus on streaming and file manipulation, but requires Node.js and can be complex for simple tasks.
- **Just**: A command runner with a focus on simplicity and ease of use, but lacks advanced features like dependency resolution and file watching.
- **Make**: Traditional build automation tool with complex syntax and limited cross-platform support.
- **npm scripts**: JavaScript-centric task runner with limited cross-platform capabilities and dependency management.
- **Pipenv**: Python package manager with task management, but limited to Python projects and lacks cross-language support.
- **Poetry**: Python dependency management tool with task management, but limited to Python projects and lacks cross-language support.
- **Rake**: Ruby-based task runner with a focus on Ruby projects, but not suitable for cross-language tasks.
- **Taskfile**: A task runner with YAML configuration, but can be verbose and less performant than `cmdfile`.

### Comparison

| Feature               | cmdfile | Make     | Just     | Taskfile |
| --------------------- | ------- | -------- | -------- | -------- |
| Language              | Zig     | C        | Rust     | Go       |
| Config Format         | TOML    | Makefile | Justfile | YAML     |
| Cross-platform        | ✅      | ✅       | ✅       | ✅       |
| Dependencies          | ✅      | ✅       | ✅       | ✅       |
| Environment Variables | ✅      | ✅       | ✅       | ✅       |
| Error Handling        | ✅      | ❌       | ❌       | ✅       |
| File Watching         | 📋      | ❌       | ❌       | ✅       |
| Interactive Prompts   | 🚧      | ❌       | ❌       | ✅       |
| Parallel Execution    | 🚧      | ✅       | ❌       | ✅       |
| Sequence Control      | 🚧      | ❌       | ❌       | ✅       |
| Shell Support         | ✅      | ✅       | ✅       | ✅       |
| Task Validation       | ✅      | ❌       | ❌       | ✅       |
| Variable Substitution | ✅      | ❌       | ✅       | ✅       |
| Zero Dependencies     | ✅      | ✅       | ✅       | ✅       |

## Current Status

`cmdfile` is in active development, is open for contributions and feedback.

### ✅ Implemented Features

- Basic task execution and validation
- Built-in testing framework
- Command-line interface with commands for initialization, listing tasks, and executing tasks
- Cross-platform shell execution
- Memory-safe implementation in Zig
- Task dependencies and dependency resolution
- TOML configuration format with full parsing

### 🚧 In Progress

- Enhanced error handling and user feedback
- Environment variable management
- Interactive prompts and confirmations
- Parallel task execution with sequence control
- Variable substitution in commands

### 📋 Planned Features

- Advanced security features like encrypted configurations and secure storage of sensitive data
- Command scheduling with cron-like syntax
- Configuration merging and inheritance
- File watching for automatic task re-execution
- Inter-process communication (IPC) integration
- Migration tools from package managers and other task runners (`package.json`, `composer.json`, `pyproject.toml`, `Cargo.toml`, `Justfile`, `Taskfile`, `Makefile`)
- Performance monitoring and metrics
- Plugin system for extensibility
- Project templates for common development setups
- Remote execution over SSH/HTTPS
- Tab completion for shells
- TUI support for task management and execution

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
cmdfile task build --dry-run

# Execute a task
cmdfile task build
```

## CLI Interface

### Usage

```shell
cmdfile <command> [task_name] [--flag[=value]...] [variable=value...] [ENVIRONMENT=value...]
```

### Commands

| Command    | Description                                   |
| ---------- | --------------------------------------------- |
| `dump`     | Dump the current configuration in TOML format |
| `help`     | Show help message or command help             |
| `init`     | Create an initial cmdfile.toml                |
| `list`     | List all available tasks                      |
| `task`     | Execute the specified task                    |
| `validate` | Validate the cmdfile.toml configuration       |
| `version`  | Show cmdfile installed version                |

### Flags

| Flag            | Description                                           |
| --------------- | ----------------------------------------------------- |
| `--config-file` | Set `cmdfile.toml` configuration file path            |
| `--dry-run`     | Show execution plan without running commands          |
| `--env-file`    | Load environment variables from specified .env file   |
| `--no-color`    | Disable colored output in logs                        |
| `--no-confirm`  | Skip user confirmation prompts before executing tasks |
| `--shell`       | Override default shell for command execution          |
| `--sudo`        | Run commands with administrative permissions          |
| `--verbose`     | Show detailed logs (info, warning, error, debug)      |
| `--work-dir`    | Set working directory for task execution              |

## Configuration File

### File Structure

```toml
[defaults]     # Global settings for all tasks
[environment]  # Environment variables
[variables]    # Reusable template values
[tasks]        # Task definitions with commands and dependencies
```

### Defaults Section

| Parameter  | Type    | Default     | Description                       |
| ---------- | ------- | ----------- | --------------------------------- |
| `env_file` | boolean | `false`     | Load environment from `.env` file |
| `shell`    | string  | `/bin/bash` | Shell for command execution       |
| `work_dir` | string  | `.`         | Base directory for tasks          |

### Variables Section

| Parameter | Type   | Description                                         |
| --------- | ------ | --------------------------------------------------- |
| `<name>`  | string | Reusable value accessible via `${name}` in commands |

### Environment Section

| Parameter    | Type   | Description                                                                          |
| ------------ | ------ | ------------------------------------------------------------------------------------ |
| `<VAR_NAME>` | string | Environment variable for task execution and accessible via `${VAR_NAME}` in commands |

### Tasks Section

| Parameter      | Type    | Required | Default | Description                                |
| -------------- | ------- | -------- | ------- | ------------------------------------------ |
| `command`      | string  | Yes      | -       | Shell command to execute                   |
| `confirm`      | boolean | No       | `false` | Require user confirmation                  |
| `dependencies` | array   | No       | `[]`    | Tasks that must complete first             |
| `description`  | string  | No       | -       | Human-readable task description            |
| `environment`  | object  | No       | `{}`    | Task-specific environment variables        |
| `prompts`      | object  | No       | `{}`    | Automated responses to interactive prompts |
| `shell`        | string  | No       | -       | Override default shell                     |
| `variables`    | object  | No       | `{}`    | Task-specific template variables           |
| `watch`        | array   | No       | `[]`    | File patterns to monitor for changes       |
| `work_dir`     | string  | No       | -       | Override default working directory         |

### Example Configuration

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
confirm = true`

[tasks.build]
description = "Build the project"
command = "npm run build"
dependencies = ["clean"]
watch = ["${src_dir}/**/*.{js,ts,css}"]

[tasks.install]
description = "Install project dependencies"
command = "npm install"
prompts = { "Do you want to install dependencies? [y/N]": "y" }

[tasks.test]
description = "Run test suite"
command = "npm test"
dependencies = ["build"]
```

## Development

### Building

```bash
# Debug build
zig build

# Release build
zig build -Doptimize=ReleaseFast

# Run tests
zig build test
```

### Project Structure

```
cmdfile/
├── build.zig              # Build configuration
├── build.zig.zon          # Dependencies
├── src/
│   ├── main.zig           # Entry point
│   ├── cli.zig            # Command line interface
│   ├── config.zig         # Configuration management
│   ├── task_runner.zig    # Core task execution
│   └── utils.zig          # Utility functions
├── test/
│   ├── cli_test.zig
│   ├── config_test.zig
│   └── task_runner_test.zig
└── cmdfile.toml           # Example configuration
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Run `zig build test` to ensure tests pass
5. Submit a pull request

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

## Roadmap

### Version 0.1.0 - Initial Release

- [x] Basic task execution and validation
- [x] Built-in testing framework
- [x] Command-line interface with commands for initialization, listing tasks, and executing tasks
- [x] Cross-platform shell execution
- [x] Memory-safe implementation in Zig
- [x] Task dependencies and dependency resolution
- [x] TOML configuration format with full parsing

### Version 0.2.0 - Enhanced Core

- [ ] Enhanced error messages and validation
- [ ] Task listing with descriptions (`cmdfile list`)
- [ ] Configuration file validation (`cmdfile validate`)
- [ ] Configuration dumping (`cmdfile dump`)

### Version 0.3.0 - Advanced Features

- [ ] Parallel task execution with sequence control (`serial`, `parallel`, `pipe`, `and`, `semi`)
- [ ] File watching for automatic re-execution
- [ ] Interactive prompts and confirmations
- [ ] Enhanced variable substitution in commands
- [ ] Environment variable management

### Version 0.4.0 - Migration & Templates

- [ ] Migration tools from YAML configuration files
- [ ] Migration from Make, Just, Taskfile, npm scripts
- [ ] Project templates for common setups (Node.js, Python, Rust, Go, etc.)
- [ ] Tab completion for shells (bash, zsh, fish)

### Version 0.5.0 - Advanced Scheduling

- [ ] Command scheduling with cron-like syntax
- [ ] File watching with advanced patterns
- [ ] Task execution history and logging
- [ ] Performance monitoring and metrics

### Version 1.0.0 - Enterprise Features

- [ ] Remote execution over SSH/HTTPS
- [ ] Inter-process communication (IPC) integration
- [ ] Plugin system for extensibility
- [ ] Configuration merging and inheritance
- [ ] Advanced security features

For detailed progress and issues, see the [GitHub Issues](https://github.com/username/cmdfile/issues) page.
