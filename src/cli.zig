const std = @import("std");
const config = @import("config.zig");

// Version information - in Ruby you might define this as a constant
// in your gemspec or a version file. Zig encourages compile-time
// constants for values that won't change at runtime.
const VERSION = "0.1.0";
const PROGRAM_NAME = "cmdfile";

// Color codes for terminal output - similar to colorize gem in Ruby
// but we're defining them as compile-time constants for efficiency
const Colors = struct {
    const reset = "\x1b[0m";
    const red = "\x1b[31m";
    const green = "\x1b[32m";
    const yellow = "\x1b[33m";
    const blue = "\x1b[34m";
    const magenta = "\x1b[35m";
    const cyan = "\x1b[36m";
    const white = "\x1b[37m";
    const bold = "\x1b[1m";
};

// Print functions that handle formatted output to stdout/stderr
// These are similar to puts/print in Ruby but with explicit
// error handling and the ability to format strings at compile time

pub fn printUsage() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}{s}Usage:{s} {s} <command> [arguments]\n", .{ Colors.bold, Colors.cyan, Colors.reset, PROGRAM_NAME });
    try stdout.print("\n", .{});
    try stdout.print("Common commands:\n", .{});
    try stdout.print("  {s}help{s}     Show detailed help information\n", .{ Colors.green, Colors.reset });
    try stdout.print("  {s}init{s}     Create a new cmdfile.yaml configuration\n", .{ Colors.green, Colors.reset });
    try stdout.print("  {s}version{s}  Show version information\n", .{ Colors.green, Colors.reset });
    try stdout.print("\n", .{});
    try stdout.print("Run '{s} help' for more detailed information.\n", .{PROGRAM_NAME});
}

pub fn printHelp() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}{s}{s} - A Simple Task Runner{s}\n", .{ Colors.bold, Colors.magenta, PROGRAM_NAME, Colors.reset });
    try stdout.print("\n", .{});
    try stdout.print("{s}DESCRIPTION:{s}\n", .{ Colors.bold, Colors.reset });
    try stdout.print("  cmdfile is a task runner that reads commands from a cmdfile.yaml\n", .{});
    try stdout.print("  configuration file. It's designed to simplify common development\n", .{});
    try stdout.print("  workflows, similar to how Rake simplifies Ruby task management.\n", .{});
    try stdout.print("\n", .{});
    try stdout.print("{s}USAGE:{s}\n", .{ Colors.bold, Colors.reset });
    try stdout.print("  {s} <command> [arguments]\n", .{PROGRAM_NAME});
    try stdout.print("\n", .{});
    try stdout.print("{s}BUILT-IN COMMANDS:{s}\n", .{ Colors.bold, Colors.reset });
    try stdout.print("  {s}help{s}         Show this help message\n", .{ Colors.green, Colors.reset });
    try stdout.print("  {s}version{s}      Show version information\n", .{ Colors.green, Colors.reset });
    try stdout.print("  {s}init{s}         Create a new cmdfile.yaml configuration file\n", .{ Colors.green, Colors.reset });
    try stdout.print("\n", .{});
    try stdout.print("{s}CONFIGURATION:{s}\n", .{ Colors.bold, Colors.reset });
    try stdout.print("  cmdfile looks for a 'cmdfile.yaml' file in the current directory.\n", .{});
    try stdout.print("  This file defines your available tasks and their commands.\n", .{});
    try stdout.print("\n", .{});
    try stdout.print("{s}EXAMPLES:{s}\n", .{ Colors.bold, Colors.reset });
    try stdout.print("  {s} init          # Create a new configuration file\n", .{PROGRAM_NAME});
    try stdout.print("  {s} build         # Run the 'build' task from cmdfile.yaml\n", .{PROGRAM_NAME});
    try stdout.print("  {s} test --watch  # Run 'test' task with additional arguments\n", .{PROGRAM_NAME});
}

pub fn printVersion() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s} version {s}\n", .{ PROGRAM_NAME, VERSION });
}

// Error printing with color formatting - similar to how you might
// use colorized output in your Ruby applications for better UX
pub fn printError(comptime fmt: []const u8, args: anytype) !void {
    const stderr = std.io.getStdErr().writer();
    try stderr.print("{s}Error:{s} ", .{ Colors.red, Colors.reset });
    try stderr.print(fmt, args);
    try stderr.print("\n", .{});
}

pub fn printSuccess(comptime fmt: []const u8, args: anytype) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}Success:{s} ", .{ Colors.green, Colors.reset });
    try stdout.print(fmt, args);
    try stdout.print("\n", .{});
}

pub fn printWarning(comptime fmt: []const u8, args: anytype) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}Warning:{s} ", .{ Colors.yellow, Colors.reset });
    try stdout.print(fmt, args);
    try stdout.print("\n", .{});
}

// Initialize a new project with a sample configuration file
// This is like running 'rails new' or creating a new gem structure
pub fn initProject(allocator: std.mem.Allocator) !void {
    _ = allocator; // We're not using the allocator in this simple version

    const stdout = std.io.getStdOut().writer();

    // Check if cmdfile.yaml already exists to avoid overwriting
    // This is similar to checking if a Gemfile exists before creating one
    if (std.fs.cwd().access("cmdfile.yaml", .{})) {
        try printWarning("cmdfile.yaml already exists. Not overwriting.", .{});
        return;
    } else |err| switch (err) {
        error.FileNotFound => {}, // This is what we want - file doesn't exist
        else => return err,
    }

    // Create a sample configuration file - this is like generating
    // a Rakefile with some common tasks predefined
    const sample_config =
        \\# cmdfile.yaml - Task Configuration
        \\# This file defines the tasks available for your project
        \\
        \\tasks:
        \\  # Development tasks
        \\  build:
        \\    description: "Build the project"
        \\    command: "echo 'Building project...'"
        \\
        \\  test:
        \\    description: "Run tests"
        \\    command: "echo 'Running tests...'"
        \\
        \\  clean:
        \\    description: "Clean build artifacts"
        \\    command: "echo 'Cleaning up...'"
        \\
        \\  dev:
        \\    description: "Start development server"
        \\    command: "echo 'Starting development server...'"
        \\
        \\  # Deployment tasks
        \\  deploy:
        \\    description: "Deploy to production"
        \\    command: "echo 'Deploying to production...'"
        \\    confirm: true  # Ask for confirmation before running
        \\
        \\# Global settings
        \\settings:
        \\  shell: "/bin/sh"  # Shell to use for executing commands
        \\  workdir: "."      # Working directory for commands
        \\
    ;

    // Write the configuration file - in Ruby you might use File.write
    // Here we're being explicit about file operations and error handling
    const file = std.fs.cwd().createFile("cmdfile.yaml", .{}) catch |err| {
        try printError("Failed to create cmdfile.yaml: {}", .{err});
        return;
    };
    defer file.close();

    _ = file.writeAll(sample_config) catch |err| {
        try printError("Failed to write to cmdfile.yaml: {}", .{err});
        return;
    };

    try printSuccess("Created cmdfile.yaml with sample tasks", .{});
    try stdout.print("\n", .{});
    try stdout.print("Available tasks:\n", .{});
    try stdout.print("  {s}build{s}   - Build the project\n", .{ Colors.cyan, Colors.reset });
    try stdout.print("  {s}test{s}    - Run tests\n", .{ Colors.cyan, Colors.reset });
    try stdout.print("  {s}clean{s}   - Clean build artifacts\n", .{ Colors.cyan, Colors.reset });
    try stdout.print("  {s}dev{s}     - Start development server\n", .{ Colors.cyan, Colors.reset });
    try stdout.print("  {s}deploy{s}  - Deploy to production\n", .{ Colors.cyan, Colors.reset });
    try stdout.print("\n", .{});
    try stdout.print("Edit cmdfile.yaml to customize these tasks for your project.\n", .{});
}

// Display available tasks from the configuration
// This is like 'rake -T' showing available tasks with descriptions
pub fn printAvailableTasks(cfg: config.Config) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n{s}Available tasks:{s}\n", .{ Colors.bold, Colors.reset });

    // In Ruby you might iterate with cfg.tasks.each
    // Here we iterate over the hash map entries explicitly
    var iterator = cfg.tasks.iterator();
    while (iterator.next()) |entry| {
        const task_name = entry.key_ptr.*;
        const task = entry.value_ptr.*;

        try stdout.print("  {s}{s:12}{s}", .{ Colors.cyan, task_name, Colors.reset });

        if (task.description) |desc| {
            try stdout.print(" - {s}", .{desc});
        }

        try stdout.print("\n", .{});
    }
}

// Tests for the CLI module - Zig's testing is built-in and fast
test "version constant is defined" {
    const testing = std.testing;
    try testing.expect(VERSION.len > 0);
    try testing.expect(std.mem.eql(u8, PROGRAM_NAME, "cmdfile"));
}

test "color codes are valid escape sequences" {
    const testing = std.testing;
    try testing.expect(Colors.red.len > 0);
    try testing.expect(Colors.green.len > 0);
    try testing.expect(Colors.reset.len > 0);
}
