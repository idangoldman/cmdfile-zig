# Project Structure for cmdfile

cmdfile/
├── build.zig              # Build configuration (like Rakefile + gemspec)
├── build.zig.zon          # Dependencies (like Gemfile)
├── src/
│   ├── main.zig           # Entry point (like bin/cmdfile)
│   ├── cli.zig            # Command line interface handling
│   ├── config.zig         # Configuration management
│   ├── task_runner.zig    # Core task execution logic
│   └── utils.zig          # Utility functions
├── test/
│   ├── cli_test.zig
│   ├── config_test.zig
│   └── task_runner_test.zig
├── cmdfile.yaml           # Example configuration file
└── README.md

## Key Differences from Ruby

1. Explicit memory management (no garbage collector)
2. Compile-time evaluation and optimization
3. Built-in testing framework
4. Cross-compilation capabilities
5. C interoperability without FFI overhead
