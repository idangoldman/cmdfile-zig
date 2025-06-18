const std = @import("std");

// String utility functions that are commonly needed in command-line tools
// These are similar to String methods in Ruby but adapted for Zig's
// explicit memory management and compile-time safety

// Check if a string starts with a given prefix
// This is like String#start_with? in Ruby but returns bool explicitly
pub fn startsWith(haystack: []const u8, needle: []const u8) bool {
    return std.mem.startsWith(u8, haystack, needle);
}

// Check if a string ends with a given suffix
// Similar to String#end_with? in Ruby
pub fn endsWith(haystack: []const u8, needle: []const u8) bool {
    return std.mem.endsWith(u8, haystack, needle);
}

// Split a string by a delimiter and return owned slices
// This is like String#split in Ruby but we need to manage memory explicitly
// The caller is responsible for freeing both the returned array and its contents
pub fn splitString(allocator: std.mem.Allocator, input: []const u8, delimiter: []const u8) ![][]u8 {
    var parts = std.ArrayList([]u8).init(allocator);
    defer parts.deinit();

    var iterator = std.mem.split(u8, input, delimiter);
    while (iterator.next()) |part| {
        const owned_part = try allocator.dupe(u8, part);
        try parts.append(owned_part);
    }

    return parts.toOwnedSlice();
}

// Free the memory allocated by splitString
// This helper makes cleanup easier for callers
pub fn freeSplitString(allocator: std.mem.Allocator, parts: [][]u8) void {
    for (parts) |part| {
        allocator.free(part);
    }
    allocator.free(parts);
}

// Join an array of strings with a separator
// This is like Array#join in Ruby but with explicit memory management
pub fn joinStrings(allocator: std.mem.Allocator, parts: []const []const u8, separator: []const u8) ![]u8 {
    if (parts.len == 0) {
        return try allocator.dupe(u8, "");
    }

    // Calculate total length needed
    var total_length: usize = 0;
    for (parts) |part| {
        total_length += part.len;
    }
    total_length += separator.len * (parts.len - 1);

    // Allocate and build the result string
    const result = try allocator.alloc(u8, total_length);
    var pos: usize = 0;

    for (parts, 0..) |part, i| {
        @memcpy(result[pos..pos + part.len], part);
        pos += part.len;

        if (i < parts.len - 1) {
            @memcpy(result[pos..pos + separator.len], separator);
            pos += separator.len;
        }
    }

    return result;
}

// File system utilities that command-line tools commonly need

// Check if a file exists
// This is like File.exist? in Ruby but uses Zig's explicit error handling
pub fn fileExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}

// Check if a directory exists
// Similar to Dir.exist? in Ruby
pub fn directoryExists(path: []const u8) bool {
    const file = std.fs.cwd().openDir(path, .{}) catch return false;
    file.close();
    return true;
}

// Get the current working directory as an owned string
// This is like Dir.pwd in Ruby but we need to manage the memory
pub fn getCurrentDirectory(allocator: std.mem.Allocator) ![]u8 {
    return std.fs.cwd().realpathAlloc(allocator, ".");
}

// Ensure a directory exists, creating it if necessary
// This is like FileUtils.mkdir_p in Ruby
pub fn ensureDirectory(path: []const u8) !void {
    std.fs.cwd().makeDir(path) catch |err| switch (err) {
        error.PathAlreadyExists => {}, // Directory already exists, which is fine
        else => return err,
    };
}

// Read a file and return its contents as an owned string
// This is like File.read in Ruby but with explicit memory management
pub fn readFileToString(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const contents = try allocator.alloc(u8, file_size);
    _ = try file.readAll(contents);

    return contents;
}

// Write a string to a file, creating it if it doesn't exist
// This is like File.write in Ruby but with explicit error handling
pub fn writeStringToFile(path: []const u8, content: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{});
    defer file.close();

    try file.writeAll(content);
}

// Environment variable utilities for working with the system environment

// Get an environment variable as an owned string
// This is like ENV['name'] in Ruby but we need to manage memory
pub fn getEnvVar(allocator: std.mem.Allocator, name: []const u8) !?[]u8 {
    const value = std.posix.getenv(name) orelse return null;
    return try allocator.dupe(u8, value);
}

// Set an environment variable for the current process
// This is like ENV['name'] = 'value' in Ruby
pub fn setEnvVar(name: []const u8, value: []const u8) !void {
    // Note: This only affects the current process, not the parent shell
    // just like in Ruby when you modify ENV
    return std.posix.setenv(name, value, 1);
}

// Process and command execution utilities

// Execute a simple command and return its exit code
// This is a simpler version of system() in Ruby for basic use cases
pub fn executeSimpleCommand(command: []const u8) !u8 {
    var child = std.process.Child.init(&[_][]const u8{ "/bin/sh", "-c", command }, std.heap.page_allocator);
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;

    try child.spawn();
    const result = try child.wait();

    switch (result) {
        .Exited => |code| return code,
        .Signal => |signal| return 128 + signal,
        .Stopped => |signal| return 128 + signal,
        .Unknown => |code| return @intCast(code),
    }
}

// Capture the output of a command as a string
// This is like backticks or %x[] in Ruby but with explicit memory management
pub fn captureCommandOutput(allocator: std.mem.Allocator, command: []const u8) ![]u8 {
    var child = std.process.Child.init(&[_][]const u8{ "/bin/sh", "-c", command }, allocator);
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;

    try child.spawn();

    // Read the output
    const stdout = child.stdout.?.reader();
    const output = try stdout.readAllAlloc(allocator, 1024 * 1024); // 1MB max

    _ = try child.wait();
    return output;
}

// Terminal and console utilities for better user interaction

// Check if we're running in a terminal (TTY)
// This is like $stdin.tty? in Ruby
pub fn isTerminal() bool {
    return std.posix.isatty(std.posix.STDIN_FILENO);
}

// Get terminal width for formatting output
// This helps format output nicely like Ruby's terminal libraries do
pub fn getTerminalWidth() u16 {
    // Try to get the actual terminal width
    if (std.posix.isatty(std.posix.STDOUT_FILENO)) {
        // This is a simplified version - a full implementation would
        // use ioctl to get the actual terminal size
        const width_str = std.posix.getenv("COLUMNS");
        if (width_str) |w| {
            return std.fmt.parseInt(u16, w, 10) catch 80;
        }
    }
    return 80; // Default width
}

// Validation utilities that are commonly needed

// Check if a string is a valid identifier (letters, numbers, underscores)
// This is useful for validating task names and other user input
pub fn isValidIdentifier(name: []const u8) bool {
    if (name.len == 0) return false;

    // First character must be letter or underscore
    if (!std.ascii.isAlphabetic(name[0]) and name[0] != '_') {
        return false;
    }

    // Rest can be letters, numbers, or underscores
    for (name[1..]) |char| {
        if (!std.ascii.isAlphanumeric(char) and char != '_') {
            return false;
        }
    }

    return true;
}

// Validate that a path is safe and doesn't contain dangerous patterns
// This helps prevent directory traversal attacks in file operations
pub fn isSafePath(path: []const u8) bool {
    // Reject paths containing ../ which could escape the working directory
    if (std.mem.indexOf(u8, path, "../") != null) return false;
    if (std.mem.indexOf(u8, path, "/..") != null) return false;
    if (std.mem.eql(u8, path, "..")) return false;

    // Reject absolute paths that could access system files
    if (path.len > 0 and path[0] == '/') return false;

    // Reject paths with null bytes
    if (std.mem.indexOf(u8, path, "\x00") != null) return false;

    return true;
}

// Tests for the utility functions - demonstrating Zig's built-in testing
test "string utilities" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Test string splitting and joining
    const input = "hello,world,test";
    const parts = try splitString(allocator, input, ",");
    defer freeSplitString(allocator, parts);

    try testing.expect(parts.len == 3);
    try testing.expect(std.mem.eql(u8, parts[0], "hello"));
    try testing.expect(std.mem.eql(u8, parts[1], "world"));
    try testing.expect(std.mem.eql(u8, parts[2], "test"));

    const const_parts: []const []const u8 = parts;
    const joined = try joinStrings(allocator, const_parts, ",");
    defer allocator.free(joined);

    try testing.expect(std.mem.eql(u8, joined, input));
}

test "validation utilities" {
    const testing = std.testing;

    // Test identifier validation
    try testing.expect(isValidIdentifier("test_task"));
    try testing.expect(isValidIdentifier("task123"));
    try testing.expect(isValidIdentifier("_private"));
    try testing.expect(!isValidIdentifier("123invalid"));
    try testing.expect(!isValidIdentifier(""));
    try testing.expect(!isValidIdentifier("invalid-name"));

    // Test path safety validation
    try testing.expect(isSafePath("safe/path/file.txt"));
    try testing.expect(isSafePath("file.txt"));
    try testing.expect(!isSafePath("../escape"));
    try testing.expect(!isSafePath("/absolute/path"));
    try testing.expect(!isSafePath("path/../escape"));
}

test "file existence checks" {
    const testing = std.testing;

    // Test with a file that should exist (this source file)
    try testing.expect(fileExists("src/utils.zig"));

    // Test with a file that shouldn't exist
    try testing.expect(!fileExists("nonexistent_file_12345.txt"));
}
