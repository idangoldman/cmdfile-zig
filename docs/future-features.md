# Future Features

## Protocol Support

- SSH
- HTTP/2
- UDP
- gRPCP

## Core

- `[crons]` as task scheduler
- `[paths]` as file system monitoring
- `[prompts]` interacts with prompts
- `[packages]` needed for the task to run including versions and lock file
- `[interface]` generate custom bin for the project based on TOML config
- Plugin system for extensibility

## Task

- `arguments` and `flags` for commands passed via stdin
- `sequence` for task execution order, ex value: `serial, parallel, pipeline, semi, and, or`
- `os` for speficic OS commands (with support of cross-platform natively)
- `sudo` for elevated permissions
- `alias` for users mostly for shorter task name or one letter
- `usage` for specification of the task

## Miscellaneous

- Task namespaces via `[task."lint:js"]` and use `[task.lint.deps] = [:js]`
- User Interface → terminal, web, graphical
- Process management
- Server → listeningo  to commands over a network
- Tab completion for shells
- Monitoring and metrics