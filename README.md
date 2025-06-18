# cmdfile

A modern task runner and build automation tool written in Zig, inspired by Rake but designed for performance and simplicity.

## Features

- **Fast**: Compiled to native code with minimal runtime overhead
- **Simple**: Clean YAML configuration syntax
- **Powerful**: Task dependencies, parallel execution, and variables
- **Cross-platform**: Runs on Linux, macOS, and Windows
- **Zero dependencies**: Self-contained binary with no runtime requirements

## Installation

### From Source

```bash
git clone https://github.com/your-username/cmdfile.git
cd cmdfile
zig build -Doptimize=ReleaseFast
# Binary will be in zig-out/bin/cmdfile
```

### Using the binary

Copy the compiled binary to your PATH:

```bash
cp zig-out/bin/cmdfile ~/.local/bin/
# or
sudo cp zig-out/bin/cmdfile /usr/local/bin/
```

## Usage

### Basic Usage

Create a `cmdfile.yaml` in your project root:

```yaml
variables:
  PROJECT_NAME: "my-project"
  BUILD_DIR: "build"

tasks:
  - name: build
    description: "Build the project"
    command: "make all"

  - name: test
    description: "Run tests"
    command: "make test"

  - name: deploy
    description: "Deploy the application"
    command: "rsync -av build/ server:/var/www/"
    dependencies:
      - build
      - test
```

Run tasks:

```bash
# List available tasks
cmdfile --list

# Run a specific task
cmdfile build

# Run multiple tasks
cmdfile test deploy

# Run with verbose output
cmdfile --verbose build
```

### Configuration

#### Variables

Variables can be defined globally and used in task commands:

```yaml
variables:
  VERSION: "1.0.0"
  DOCKER_IMAGE: "myapp:${VERSION}"

tasks:
  - name: docker-build
    command: "docker build -t ${DOCKER_IMAGE} ."
```

#### Task Dependencies

Tasks can depend on other tasks:

```yaml
tasks:
  - name: compile
    command: "gcc -o app main.c"

  - name: test
    command: "./app --test"
    dependencies:
      - compile

  - name: package
    command: "tar -czf app.tar.gz app"
    dependencies:
      - compile
      - test
```

#### Parallel Execution

Independent tasks run in parallel automatically:

```yaml
tasks:
  - name: lint-js
    command: "eslint src/"

  - name: lint-css
    command: "stylelint styles/"

  - name: lint-all
    dependencies:
      - lint-js  # These run in parallel
      - lint-css # since they're independent
```

## Command Line Options

- `--list`, `-l`: List all available tasks
- `--verbose`, `-v`: Enable verbose output
- `--config`, `-c`: Specify custom config file path
- `--help`, `-h`: Show help message
- `--version`: Show version information

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

```text
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
└── cmdfile.yaml           # Example configuration
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run `zig build test` to ensure tests pass
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Comparison with Other Tools

| Feature | cmdfile | Make | Rake | Just |
|---------|---------|------|------|------|
| Language | Zig | C | Ruby | Rust |
| Config Format | YAML | Makefile | Ruby DSL | Justfile |
| Parallel Execution | ✅ | ✅ | ✅ | ✅ |
| Cross-platform | ✅ | ⚠️ | ✅ | ✅ |
| Single Binary | ✅ | ✅ | ❌ | ✅ |
| Variables | ✅ | ✅ | ✅ | ✅ |
| Zero Dependencies | ✅ | ✅ | ❌ | ✅ |

## Examples

See the `examples/` directory for more complex usage examples including:

- Multi-language projects
- Docker workflows
- CI/CD integration
- Advanced dependency patterns
