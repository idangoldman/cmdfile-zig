const std = @import("std");
const cli = @import("cli.zig");
const config = @import("config.zig");
const task_runner = @import("task_runner.zig");

// In Zig, main returns an error union type. This is more explicit
// than Ruby's implicit exception handling - you declare upfront
// that your function might fail, similar to how you'd rescue
// exceptions in Ruby, but at the type level.
pub fn main() !void {
    // Memory management in Zig is explicit. We need to create
    // an allocator - think of this as managing your own memory
    // pool instead of relying on Ruby's garbage collector.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit(); // This runs when the function exits, like Ruby's ensure

    const allocator = gpa.allocator();

    // Parse command line arguments - similar to OptionParser in Ruby
    // but more explicit about memory and error handling
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args); // Clean up memory when done

    // Handle the case where no arguments are provided
    // In Ruby you might use ARGV.empty?, here we check array length
    if (args.len < 2) {
        try cli.printUsage();
        return;
    }

    // Parse the command from arguments - args[0] is the program name,
    // args[1] is the first actual argument (like ARGV[0] in Ruby)
    const command = args[1];

    // Handle built-in commands first - these are like your rake tasks
    // but handled directly in the main flow rather than through
    // a task discovery system
    if (std.mem.eql(u8, command, "help") or std.mem.eql(u8, command, "--help")) {
        try cli.printHelp();
        return;
    }

    if (std.mem.eql(u8, command, "version") or std.mem.eql(u8, command, "--version")) {
        try cli.printVersion();
        return;
    }

    if (std.mem.eql(u8, command, "init")) {
        try cli.initProject(allocator);
        return;
    }

    // Load configuration - this is like loading your Rakefile
    // but we're explicit about where it comes from and handle
    // the case where it doesn't exist
    var cfg = config.loadConfig(allocator) catch |err| switch (err) {
        error.FileNotFound => {
            try cli.printError("No cmdfile.yaml found. Run 'cmdfile init' to create one.", .{});
            return;
        },
        else => return err, // Re-throw other errors
    };
    defer cfg.deinit(); // Clean up config memory

    // Execute the requested task - this is the core of your task runner
    // Similar to how rake finds and executes tasks, but with explicit
    // error handling and memory management

    // Convert [:0]u8 args to []const u8 args for the task runner
    const task_args = try allocator.alloc([]const u8, args[2..].len);
    defer allocator.free(task_args);
    for (args[2..], 0..) |arg, i| {
        task_args[i] = arg[0..];
    }

    task_runner.executeTask(allocator, cfg, command, task_args) catch |err| switch (err) {
        error.TaskNotFound => {
            try cli.printError("Task not found: {s}", .{command});
            try cli.printAvailableTasks(cfg);
        },
        error.TaskFailed => {
            try cli.printError("Task execution failed: {s}", .{command});
            std.process.exit(1);
        },
        else => return err,
    };
}

// Zig has built-in testing support - no need for external gems
// Tests are written right alongside your code and run with 'zig test'
test "main module imports" {
    // This test ensures all our imports are valid
    // Similar to a smoke test in Ruby that checks basic functionality
    const testing = std.testing;

    // Test that our modules can be imported without error
    _ = cli;
    _ = config;
    _ = task_runner;

    // If we get here without compile errors, the test passes
    try testing.expect(true);
}
