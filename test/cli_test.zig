const std = @import("std");
const cli = @import("../src/cli.zig");
const config = @import("../src/config.zig");

// Test for the CLI module functionality
// Zig's testing framework is built-in and doesn't require external dependencies
// like RSpec or minitest in Ruby. Tests run at compile time when possible,
// giving you immediate feedback about correctness.

test "CLI module basic functionality" {
    const testing = std.testing;

    // Test that our CLI module imports correctly
    // This is like a basic smoke test in Ruby testing
    _ = cli;

    // If we reach this point, the module loaded successfully
    try testing.expect(true);
}

// Test the init project functionality with a temporary directory
// This demonstrates how to test file operations in Zig while keeping
// tests isolated and not affecting the real file system
test "init project creates configuration file" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create a temporary directory for testing
    // This is like using Dir.mktmpdir in Ruby tests
    var tmp_dir = testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    // Change to the temporary directory for the test
    const original_dir = std.fs.cwd();
    defer std.posix.chdir(original_dir.fd) catch {};

    try std.posix.chdir(tmp_dir.dir.fd);

    // Run the init command
    try cli.initProject(allocator);

    // Verify that the file was created
    const file_exists = tmp_dir.dir.access("cmdfile.yaml", .{}) catch false;
    try testing.expect(file_exists);

    // Verify the file has content
    const content = try tmp_dir.dir.readFileAlloc(allocator, "cmdfile.yaml", 1024 * 1024);
    defer allocator.free(content);

    try testing.expect(content.len > 0);
    try testing.expect(std.mem.indexOf(u8, content, "tasks:") != null);
    try testing.expect(std.mem.indexOf(u8, content, "build:") != null);
}

// Test that init doesn't overwrite existing files
// This tests the safety feature that prevents accidental overwrites
test "init respects existing configuration" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tmp_dir = testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const original_dir = std.fs.cwd();
    defer std.posix.chdir(original_dir.fd) catch {};

    try std.posix.chdir(tmp_dir.dir.fd);

    // Create an existing file
    const existing_content = "# Existing configuration\n";
    try tmp_dir.dir.writeFile("cmdfile.yaml", existing_content);

    // Try to init (should not overwrite)
    try cli.initProject(allocator);

    // Verify the original content is preserved
    const content = try tmp_dir.dir.readFileAlloc(allocator, "cmdfile.yaml", 1024);
    defer allocator.free(content);

    try testing.expect(std.mem.eql(u8, content, existing_content));
}

// Integration test that loads and validates a configuration
// This tests the interaction between multiple modules
test "configuration loading and validation" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tmp_dir = testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const original_dir = std.fs.cwd();
    defer std.posix.chdir(original_dir.fd) catch {};

    try std.posix.chdir(tmp_dir.dir.fd);

    // Create a test configuration file
    const test_config =
        \\tasks:
        \\  test_task:
        \\    description: "A test task"
        \\    command: "echo 'test command'"
        \\
        \\settings:
        \\  shell: "/bin/bash"
        \\
    ;

    try tmp_dir.dir.writeFile("cmdfile.yaml", test_config);

    // Load the configuration
    var cfg = try config.loadConfig(allocator);
    defer cfg.deinit();

    // Verify the configuration was loaded correctly
    try testing.expect(cfg.tasks.count() == 1);

    const task = cfg.getTask("test_task");
    try testing.expect(task != null);
    try testing.expect(std.mem.eql(u8, task.?.command, "echo 'test command'"));
    try testing.expect(task.?.description != null);
    try testing.expect(std.mem.eql(u8, task.?.description.?, "A test task"));

    try testing.expect(std.mem.eql(u8, cfg.settings.shell, "/bin/bash"));
}

// Test error handling for missing configuration file
// This verifies that our error handling works correctly
test "missing configuration file handling" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tmp_dir = testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const original_dir = std.fs.cwd();
    defer std.posix.chdir(original_dir.fd) catch {};

    try std.posix.chdir(tmp_dir.dir.fd);

    // Try to load configuration when no file exists
    const result = config.loadConfig(allocator);

    // Should return FileNotFound error
    try testing.expectError(error.FileNotFound, result);
}

// Performance test to ensure operations complete in reasonable time
// This is like benchmark tests in Ruby but built into the testing framework
test "configuration loading performance" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tmp_dir = testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const original_dir = std.fs.cwd();
    defer std.posix.chdir(original_dir.fd) catch {};

    try std.posix.chdir(tmp_dir.dir.fd);

    // Create a larger configuration file to test performance
    var config_content = std.ArrayList(u8).init(allocator);
    defer config_content.deinit();

    try config_content.appendSlice("tasks:\n");

    // Add many tasks to test with a larger configuration
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        const task_definition = try std.fmt.allocPrint(allocator,
            \\  task_{d}:
            \\    description: "Test task {d}"
            \\    command: "echo 'Task {d}'"
            \\
        , .{ i, i, i });
        defer allocator.free(task_definition);

        try config_content.appendSlice(task_definition);
    }

    try tmp_dir.dir.writeFile("cmdfile.yaml", config_content.items);

    // Measure loading time
    const start_time = std.time.nanoTimestamp();

    var cfg = try config.loadConfig(allocator);
    defer cfg.deinit();

    const end_time = std.time.nanoTimestamp();
    const duration_ms = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000.0;

    // Verify we loaded all tasks
    try testing.expect(cfg.tasks.count() == 100);

    // Loading should complete quickly (under 100ms for 100 tasks)
    try testing.expect(duration_ms < 100.0);

    std.log.info("Loaded 100 tasks in {d:.2}ms", .{duration_ms});
}

// Memory leak detection test
// This ensures our memory management is correct and we're not leaking
test "memory management correctness" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        std.testing.expect(leaked == .ok) catch @panic("Memory leak detected!");
    }
    const allocator = gpa.allocator();

    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const original_dir = std.fs.cwd();
    defer std.posix.chdir(original_dir.fd) catch {};

    try std.posix.chdir(tmp_dir.dir.fd);

    // Run init multiple times to test for leaks
    var iteration: u32 = 0;
    while (iteration < 10) : (iteration += 1) {
        // Remove any existing file
        tmp_dir.dir.deleteFile("cmdfile.yaml") catch {};

        // Run init
        try cli.initProject(allocator);

        // Load and immediately destroy configuration
        var cfg = try config.loadConfig(allocator);
        cfg.deinit();
    }

    // If we get here without the deferred panic, no memory was leaked
}
