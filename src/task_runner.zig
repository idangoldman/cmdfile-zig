const std = @import("std");
const config = @import("config.zig");
const cli = @import("cli.zig");

// Execute a task by name with optional arguments
// This is the heart of your task runner - similar to how Rake
// finds and executes tasks, but with explicit error handling
// and process management that Zig provides
pub fn executeTask(
    allocator: std.mem.Allocator,
    cfg: config.Config,
    task_name: []const u8,
    args: [][]const u8
) !void {
    // Look up the task in our configuration
    // This is like finding a task in Rake, but we handle the
    // "not found" case explicitly rather than raising an exception
    const task = cfg.getTask(task_name) orelse {
        return error.TaskNotFound;
    };

    // Ask for confirmation if the task requires it
    // This is useful for destructive operations like deployment
    if (task.confirm) {
        const confirmation = try askForConfirmation(allocator, task_name);
        if (!confirmation) {
            try cli.printWarning("Task cancelled by user", .{});
            return;
        }
    }

    try cli.printSuccess("Running task: {s}", .{task_name});

    // Print the command being executed for transparency
    // This helps with debugging and gives users confidence
    // about what's actually happening
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Command: {s}\n", .{task.command});

    // Build the complete command with any additional arguments
    // In Ruby you might use string interpolation or array joins
    // Here we're explicit about memory allocation and string building
    const full_command = try buildCommand(allocator, task, args);
    defer allocator.free(full_command);

    // Execute the command using the appropriate shell
    // This is where Zig's explicit process management shines
    // compared to Ruby's system() or backticks
    const exit_code = try executeCommand(
        allocator,
        full_command,
        task.shell orelse cfg.settings.shell,
        task.workdir orelse cfg.settings.workdir,
        task.env
    );

    // Handle the exit code appropriately
    // Unlike Ruby where you might check $? after system calls,
    // Zig lets us handle this explicitly in our control flow
    if (exit_code != 0) {
        try cli.printError("Task failed with exit code: {d}", .{exit_code});
        return error.TaskFailed;
    }

    try cli.printSuccess("Task completed successfully", .{});
}

// Build the complete command string with arguments
// This function handles combining the base command with any
// additional arguments passed on the command line
fn buildCommand(
    allocator: std.mem.Allocator,
    task: *const config.Task,
    args: [][]const u8
) ![]u8 {
    // Start with the base command from the task definition
    var command_parts = std.ArrayList([]const u8).init(allocator);
    defer command_parts.deinit();

    try command_parts.append(task.command);

    // Add any additional arguments passed to the task
    // This is like ARGV in Ruby - arguments passed after the task name
    for (args) |arg| {
        try command_parts.append(arg);
    }

    // Join all parts with spaces - similar to Array#join in Ruby
    // but we need to calculate the total length and allocate memory explicitly
    var total_length: usize = 0;
    for (command_parts.items) |part| {
        total_length += part.len;
    }
    // Add space for separating spaces
    total_length += command_parts.items.len - 1;

    const result = try allocator.alloc(u8, total_length);
    var pos: usize = 0;

    for (command_parts.items, 0..) |part, i| {
        @memcpy(result[pos..pos + part.len], part);
        pos += part.len;

        // Add space between parts (except after the last one)
        if (i < command_parts.items.len - 1) {
            result[pos] = ' ';
            pos += 1;
        }
    }

    return result;
}

// Execute a command in a specific shell and working directory
// This is the low-level function that actually runs commands
// In Ruby you might use system(), ``, or Open3 - here we use
// Zig's explicit process management for better control
fn executeCommand(
    allocator: std.mem.Allocator,
    command: []const u8,
    shell: []const u8,
    workdir: []const u8,
    env_vars: ?std.StringHashMap([]const u8)
) !u8 {
    // Prepare the shell command - we run the command through a shell
    // so that features like pipes, redirects, and variable expansion work
    var shell_args = std.ArrayList([]const u8).init(allocator);
    defer shell_args.deinit();

    try shell_args.append(shell);
    try shell_args.append("-c");
    try shell_args.append(command);

    // Set up the child process - this is more explicit than Ruby's
    // process spawning but gives us fine-grained control over
    // the execution environment
    var child_process = std.process.Child.init(shell_args.items, allocator);

    // Set the working directory if specified
    // This is like Dir.chdir in Ruby but scoped to just this process
    if (!std.mem.eql(u8, workdir, ".")) {
        child_process.cwd = workdir;
    }

    // Set up environment variables if provided
    // This is like ENV in Ruby but we build it explicitly
    if (env_vars) |vars| {
        var env_map = std.process.EnvMap.init(allocator);
        defer env_map.deinit();

        // Start with the current environment
        try env_map.inherit(allocator);

        // Add or override with task-specific variables
        var var_iterator = vars.iterator();
        while (var_iterator.next()) |entry| {
            try env_map.put(entry.key_ptr.*, entry.value_ptr.*);
        }

        child_process.env_map = &env_map;
    }

    // Inherit stdin/stdout/stderr so the command can interact with the user
    // This is like system() in Ruby where output goes directly to the terminal
    child_process.stdin_behavior = .Inherit;
    child_process.stdout_behavior = .Inherit;
    child_process.stderr_behavior = .Inherit;

    // Start the process and wait for it to complete
    // This is explicit compared to Ruby's system() which hides these steps
    try child_process.spawn();
    const result = try child_process.wait();

    // Extract the exit code from the process result
    switch (result) {
        .Exited => |code| return code,
        .Signal => |signal| {
            try cli.printError("Process terminated by signal: {d}", .{signal});
            return 128 + signal; // Standard Unix convention for signal exits
        },
        .Stopped => |signal| {
            try cli.printError("Process stopped by signal: {d}", .{signal});
            return 128 + signal;
        },
        .Unknown => |code| {
            try cli.printError("Process exited with unknown status: {d}", .{code});
            return @intCast(code);
        },
    }
}

// Ask the user for confirmation before running a task
// This is useful for destructive operations like deployment or cleanup
// Similar to how you might use confirm prompts in Ruby CLI applications
fn askForConfirmation(allocator: std.mem.Allocator, task_name: []const u8) !bool {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    try stdout.print("Are you sure you want to run '{s}'? [y/N]: ", .{task_name});

    // Read user input - this is more explicit than gets or readline in Ruby
    const input_buffer = try allocator.alloc(u8, 256);
    defer allocator.free(input_buffer);

    if (try stdin.readUntilDelimiterOrEof(input_buffer, '\n')) |input| {
        const trimmed = std.mem.trim(u8, input, " \t\r\n");

        // Accept 'y', 'Y', 'yes', 'Yes', etc.
        return std.mem.eql(u8, trimmed, "y") or
               std.mem.eql(u8, trimmed, "Y") or
               std.mem.eql(u8, trimmed, "yes") or
               std.mem.eql(u8, trimmed, "Yes") or
               std.mem.eql(u8, trimmed, "YES");
    }

    return false; // Default to no if no input or EOF
}

// List all available tasks from the configuration
// This is like 'rake -T' in the Ruby world
pub fn listTasks(cfg: config.Config) !void {
    const stdout = std.io.getStdOut().writer();

    if (cfg.tasks.count() == 0) {
        try cli.printWarning("No tasks defined in cmdfile.yaml", .{});
        return;
    }

    try stdout.print("Available tasks:\n\n");

    // Iterate through tasks and display them with descriptions
    // In Ruby you might use Hash#each, here we use explicit iteration
    var task_iterator = cfg.tasks.iterator();
    while (task_iterator.next()) |entry| {
        const task_name = entry.key_ptr.*;
        const task = entry.value_ptr.*;

        try stdout.print("  {s}", .{task_name});

        if (task.description) |desc| {
            // Add padding for alignment
            const padding = if (task_name.len < 12) 12 - task_name.len else 1;
            var i: usize = 0;
            while (i < padding) : (i += 1) {
                try stdout.print(" ");
            }
            try stdout.print("# {s}", .{desc});
        }

        try stdout.print("\n");
    }
}

// Validate that a task exists and can be executed
// This is useful for pre-flight checks before attempting execution
pub fn validateTask(cfg: config.Config, task_name: []const u8) !void {
    const task = cfg.getTask(task_name) orelse {
        return error.TaskNotFound;
    };

    if (task.command.len == 0) {
        return error.EmptyCommand;
    }

    // Could add more validations here:
    // - Check if shell exists
    // - Verify working directory exists
    // - Validate environment variables
}

// Tests for the task runner module
test "build command with no arguments" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const task = config.Task{
        .command = "echo hello",
    };

    const args: [][]const u8 = &.{};
    const result = try buildCommand(allocator, &task, args);
    defer allocator.free(result);

    try testing.expect(std.mem.eql(u8, result, "echo hello"));
}

test "build command with arguments" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const task = config.Task{
        .command = "echo",
    };

    const args = [_][]const u8{ "hello", "world" };
    const result = try buildCommand(allocator, &task, &args);
    defer allocator.free(result);

    try testing.expect(std.mem.eql(u8, result, "echo hello world"));
}

test "validate existing task" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var cfg = config.Config.init(allocator);
    defer cfg.deinit();

    const task = config.Task{
        .command = "echo test",
    };

    try cfg.addTask("test", task);
    try validateTask(cfg, "test");
}

test "validate non-existent task" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var cfg = config.Config.init(allocator);
    defer cfg.deinit();

    const result = validateTask(cfg, "nonexistent");
    try testing.expectError(error.TaskNotFound, result);
}
