# cmdfile Development Roadmap

> **Refined Implementation Plan for a Modern CLI Task Runner**

This roadmap presents actionable items for cmdfile development, structured by version releases leading to **0.6.0 MVP** - a production-ready CLI tool.

## 🎯 Version Overview

| Version | Focus Area | Status |
|---------|------------|--------|
| [0.1.0](#phase-1-foundation-version-010) | Foundation | 🚧 In Progress |
| [0.2.0](#phase-2-enhanced-features-version-020) | Enhanced Features | 📋 Planned |
| [0.3.0](#phase-3-advanced-features-version-030) | Advanced Features | 📋 Planned |
| [0.4.0](#phase-4-migration--integration-version-040) | Migration & Integration | 📋 Planned |
| [0.5.0](#phase-5-file-system-integration-version-050) | File System Integration | 📋 Planned |
| [0.6.0](#phase-6-mvp-production-ready-version-060) | MVP Production Ready | 📋 Planned |

---

## Phase 1: Foundation (Version 0.1.0)

> **Goal**: Establish core functionality with basic task execution and configuration management.

### Schema Architecture & Code Generation

#### Action 1.1: Create core schema files with single aliases

- [x] Create `schemas/structs/task.toml` with: command/cmd, description/desc, dependencies/deps, examples, confirm
- [x] Add `default` property specifications for: confirm (false), shell (platform-specific), work_dir (".")
- [x] Use single alias per property: command→cmd, description→desc, dependencies→deps
- [x] Create `schemas/structs/config.toml` with: version, global, tasks, variables, environment, validation

#### Action 1.2: Implement comptime schema reader with zig-toml

- [ ] Integrate `zig-toml` dependency for schema file parsing in `src/schema/reader.zig`
- [ ] Generate structs with single alias mapping and default value handling
- [ ] Create validation functions that apply schema defaults
- [ ] Output generated code to `src/generated/structs.zig`

#### Action 1.3: Create TOML configuration parser

- [ ] Implement configuration parser using `zig-toml`
- [ ] Add alias resolution during parsing (accept both full names and single aliases)
- [ ] Implement proper default value inheritance (global → task-specific)
- [ ] Create configuration file discovery with fallback behavior

#### Action 1.4: Add configuration validation

- [ ] Validate task name patterns and dependency references
- [ ] Apply schema defaults during parsing
- [ ] Implement circular dependency detection
- [ ] Add helpful error messages with context

### Core CLI Implementation

#### Action 1.5: Implement basic CLI commands

- [ ] Complete `src/cli.zig` with: init, list, validate, version, help commands
- [ ] Update `cmdfile init` to generate TOML configuration
- [ ] Implement `cmdfile list` to show tasks with descriptions
- [ ] Implement `cmdfile validate` to check configuration

#### Action 1.6: Add examples as property value suggestions

- [ ] Parse examples from task configuration as typed values (strings, numbers, booleans)
- [ ] Support examples for any property type (command examples, timeout examples, etc.)
- [ ] Display examples in `cmdfile help <task>` output as suggested values
- [ ] Validate examples match their property types during configuration parsing

#### Action 1.7: Fix argument parsing

- [ ] Improve command-line argument handling
- [ ] Add task execution argument passing
- [ ] Implement command-line flag override precedence
- [ ] Add proper error handling for invalid commands

### Basic Task Execution

#### Action 1.8: Implement linear dependency resolution

- [ ] Create dependency graph builder
- [ ] Implement topological sort for execution sequence
- [ ] Add circular dependency detection with clear error messages
- [ ] Support simple dependency chains

#### Action 1.9: Implement basic variable substitution (non-recursive)

- [ ] Support `${variable}` syntax in task commands without nesting
- [ ] Implement variable resolution from global configuration
- [ ] Add environment variable access via `${ENV_VAR}` syntax
- [ ] Apply variable values where configured

#### Action 1.10: Implement cross-platform task execution

- [ ] Detect and apply platform-appropriate shell (bash/zsh on Unix, cmd on Windows)
- [ ] Implement working directory management
- [ ] Add environment variable inheritance
- [ ] Handle command escaping with platform-specific handling

### Testing Infrastructure

#### Action 1.11: Complete test files

- [ ] Finish tests in `test/cli_test.zig` including validation testing
- [ ] Complete tests in `test/config_test.zig` with parsing testing
- [ ] Finish tests in `test/task_runner_test.zig` with execution validation
- [ ] Add integration tests for complete workflows

#### Action 1.12: Set up CI/CD pipeline

- [ ] Configure multi-platform builds
- [ ] Add automated testing
- [ ] Implement test coverage reporting
- [ ] Add performance regression detection

### Documentation & User Experience

#### Action 1.13: Create comprehensive error handling

- [ ] Implement structured error types
- [ ] Add context and suggestions to error messages
- [ ] Create error recovery mechanisms
- [ ] Add debug mode with verbose logging

#### Action 1.14: Add progress indication

- [ ] Implement task output streaming
- [ ] Add progress indicators
- [ ] Create configurable log levels
- [ ] Add execution timing display

---

## Phase 2: Enhanced Features (Version 0.2.0)

> **Goal**: Improve user experience with advanced configuration and better task management.

### Advanced Variable and Environment System

#### Action 2.1: Implement task-local variables

- [ ] Extend schema to support per-task variable definitions
- [ ] Implement variable scoping (task → global → environment)
- [ ] Add validation for variable scope conflicts
- [ ] Update variable substitution to handle scope hierarchy

#### Action 2.2: Add environment file support

- [ ] Implement `.env` file parsing
- [ ] Add automatic `.env` loading when `env_file = true`
- [ ] Support custom env file paths
- [ ] Merge env file variables with configuration variables

### Enhanced Task Features

#### Action 2.3: Add confirmation prompts

- [ ] Implement interactive confirmation for tasks with `confirm = true`
- [ ] Add automatic confirmation bypass for CI environments
- [ ] Support batch confirmation with timeout handling
- [ ] Add confirmation prompt styling

#### Action 2.4: Implement enhanced dependency features

- [ ] Add dependency validation
- [ ] Implement dependency visualization
- [ ] Add support for optional dependencies
- [ ] Create dependency caching

### User Experience Improvements

#### Action 2.5: Enhanced CLI output

- [ ] Add colored output with `--no-color` flag support
- [ ] Implement table formatting for task lists
- [ ] Add status indicators
- [ ] Create consistent output formatting

#### Action 2.6: Add comprehensive validations

- [ ] Validate shell paths with platform-specific checks
- [ ] Check working directories
- [ ] Validate environment variable names
- [ ] Add warnings for configuration issues

#### Action 2.7: Enhanced examples system

- [ ] Add examples validation for all property types (strings, numbers, booleans, arrays)
- [ ] Implement example-based command completion suggestions
- [ ] Create example interpolation in help output
- [ ] Add example-based configuration validation

---

## Phase 3: Advanced Features (Version 0.3.0)

> **Goal**: Add advanced execution capabilities and configuration management.

### Parallel Execution

#### Action 3.1: Implement parallel task execution

- [ ] Design task scheduler with concurrency limits
- [ ] Implement resource limits with max concurrent tasks
- [ ] Add parallel execution while preserving dependency order
- [ ] Create process isolation

#### Action 3.2: Add execution strategies

- [ ] Support different execution modes (serial, parallel, mixed)
- [ ] Add task timeout support with numeric examples
- [ ] Implement task cancellation and signal handling
- [ ] Add graceful shutdown procedures

### Advanced Configuration

#### Action 3.3: Implement configuration inheritance

- [ ] Support configuration file imports/includes
- [ ] Add base configuration with environment-specific overrides
- [ ] Implement inheritance conflict resolution
- [ ] Add validation for inheritance cycles

#### Action 3.4: Enhanced examples and validation

- [ ] Add dynamic example generation based on project context
- [ ] Implement example-based property suggestions during configuration
- [ ] Create example validation with type checking
- [ ] Add example-based error recovery suggestions

---

## Phase 4: Migration & Integration (Version 0.4.0)

> **Goal**: Provide seamless migration from existing tools and enhance developer workflow integration.

### Migration Tools

#### Action 4.1: Implement npm scripts migration

- [ ] Create `cmdfile migrate npm` command
- [ ] Parse `package.json` scripts section
- [ ] Convert npm script patterns to cmdfile tasks
- [ ] Handle npm script composition and dependencies

#### Action 4.2: Implement additional migration tools

- [ ] Add `cmdfile migrate makefile` for Makefile conversion
- [ ] Add `cmdfile migrate composer` for composer.json scripts
- [ ] Add `cmdfile migrate taskfile` for Taskfile.yml conversion
- [ ] Create generic migration framework

### Developer Integration

#### Action 4.3: Implement shell completion

- [ ] Generate bash completion scripts
- [ ] Add zsh completion support
- [ ] Create fish shell completion
- [ ] Add completion installation instructions

#### Action 4.4: Add IDE support

- [ ] Generate JSON Schema from TOML schemas for IDE integration
- [ ] Create Language Server Protocol support for configuration files
- [ ] Add syntax highlighting definitions
- [ ] Create IDE extension documentation

---

## Phase 5: File System Integration (Version 0.5.0)

> **Goal**: Add intelligent file watching and path-based task automation.

### Path Management System

#### Action 5.1: Design and implement paths infrastructure

- [ ] Create `schemas/structs/paths.toml` with pattern, watch properties
- [ ] Implement path pattern management with glob syntax
- [ ] Add file system integration with monitoring behavior
- [ ] Create path reference system for task command substitution

#### Action 5.2: Implement file watching foundation

- [ ] Add file system monitoring using Zig's `std.fs.watch`
- [ ] Implement change detection with debouncing intervals
- [ ] Create watch event processing with event filtering
- [ ] Add watch pattern validation

### File-Driven Task Execution

#### Action 5.3: Add path-aware task execution

- [ ] Implement path resolution during task command building
- [ ] Add file list generation for watched paths
- [ ] Create path-based conditional execution
- [ ] Add working directory management relative to path definitions

#### Action 5.4: Implement intelligent file watching

- [ ] Add advanced change detection algorithms
- [ ] Implement pattern-based file filtering with exclusion patterns
- [ ] Create watch event aggregation strategies
- [ ] Add performance optimization with caching mechanisms

### Advanced File System Features

#### Action 5.5: Add comprehensive path features

- [ ] Implement path composition and inheritance
- [ ] Add path-based environment variable injection
- [ ] Create path-specific execution contexts
- [ ] Add path validation with security restrictions

#### Action 5.6: Implement file-driven automation

- [ ] Create automatic task triggering based on file changes
- [ ] Add incremental execution based on file dependencies
- [ ] Implement build caching strategies
- [ ] Add file change impact analysis

---

## Phase 6: MVP Production Ready (Version 0.6.0)

> **Goal**: Deliver a production-ready CLI tool with comprehensive testing and user experience polish.

### Production Hardening

#### Action 6.1: Performance optimization

- [ ] Complete performance optimization across all modules
- [ ] Implement memory usage optimization
- [ ] Add startup time optimization (<100ms)
- [ ] Complete cross-platform compatibility testing

#### Action 6.2: Enhanced error handling and recovery

- [ ] Implement comprehensive error recovery mechanisms
- [ ] Add detailed error context with examples-based suggestions
- [ ] Create user-friendly error messages with actionable advice
- [ ] Add error reporting and debugging tools

### Final Testing and Validation

#### Action 6.3: Comprehensive testing

- [ ] Achieve >95% test coverage
- [ ] Complete stress testing and performance benchmarks
- [ ] Validate all migration tools with real projects
- [ ] Conduct security audit and vulnerability assessment

#### Action 6.4: User experience polish

- [ ] Complete user interface consistency across all commands
- [ ] Add comprehensive help system with examples
- [ ] Implement user onboarding improvements
- [ ] Create example-driven quick start guides

### Documentation and Release

#### Action 6.5: Documentation and packaging

- [ ] Complete comprehensive user and developer documentation
- [ ] Create installation packages (homebrew, apt, chocolatey, direct binary)
- [ ] Add automatic update mechanism
- [ ] Create tutorial and example project repositories

#### Action 6.6: Release infrastructure

- [ ] Set up automated release pipeline
- [ ] Create package distribution infrastructure
- [ ] Implement basic telemetry and crash reporting
- [ ] Establish community contribution guidelines and issue templates

---

## 📋 Implementation Guidelines

### Examples System Design

The examples system enhances developer experience by providing concrete, typed value suggestions:

- **Typed Values**: Examples support strings, numbers, booleans, and arrays
- **Property Suggestions**: Examples provide concrete suggestions for any configuration property
- **Validation**: Examples are validated against their property types during schema validation
- **User Experience**: Examples enhance completion systems and help output

```toml
[tasks.build]
command = "npm run build"
examples = [
    "npm run build",
    "yarn build",
    "pnpm build"
]
timeout = 300
examples_timeout = [60, 120, 300, 600]
```

### Schema Design Principles

- **Sensible Defaults**: Every configurable property should have a sensible default where applicable
- **Platform-Specific**: Platform-specific behavior should be handled in code generation
- **Single Alias**: One alias per property to avoid confusion (command→cmd, description→desc)
- **Comprehensive Examples**: Examples should cover common use cases and edge cases

### Quality Gates

All phases must meet these requirements:

- ✅ **Cross-Platform**: Tested on Windows, macOS, and Linux
- ✅ **Memory Safe**: No memory leaks detected
- ✅ **Performance**: Meets established benchmarks
- ✅ **Documentation**: Updated for all user-facing changes
- ✅ **Migration**: Breaking changes include migration path

### Version Strategy

| Version | Milestone | Description |
|---------|-----------|-------------|
| **0.1.0** | Foundation | Core functionality with basic task execution |
| **0.2.0** | Enhanced UX | Improved user experience and configuration |
| **0.3.0** | Advanced Features | Parallel execution and advanced configuration |
| **0.4.0** | Integration | Migration tools and developer workflow integration |
| **0.5.0** | File System | Intelligent file watching and path-based automation |
| **0.6.0** | MVP Ready | Production-ready CLI tool with comprehensive testing |

---

## 🚀 Getting Started

To contribute to cmdfile development:

1. **Check the current phase** and find actionable items
2. **Review implementation guidelines** for quality standards
3. **Create focused PRs** for individual action items
4. **Include comprehensive tests** for all functionality
5. **Update documentation** for user-facing changes

Each action item can be broken down into smaller tasks during implementation while maintaining the overall architectural vision.

---

**Next Steps**: Begin with Phase 1 foundation work, starting with schema architecture and core CLI implementation.
