const std = @import("std");

// In Zig, we define data structures explicitly rather than relying
// on dynamic hashes like Ruby. This gives us compile-time type safety
// and better performance, but requires more upfront thinking about
// our data model.

// A single task definition - like a Rake task but with explicit fields
pub const Task = struct {
    description: ?[]const u8 = null, // Optional description string
    command: []const u8, // The actual command to execute
    confirm: bool = false, // Whether to ask for confirmation
    workdir: ?[]const u8 = null, // Working directory for this task
    shell: ?[]const u8 = null, // Shell to use for this task
    env: ?std.StringHashMap([]const u8) = null, // Environment variables

    // Memory cleanup function - this is explicit in Zig whereas
    // Ruby's garbage collector handles this automatically
    pub fn deinit(self: *Task, allocator: std.mem.Allocator) void {
        if (self.env) |*env_map| {
            var iterator = env_map.iterator();
            while (iterator.next()) |entry| {
                allocator.free(entry.key_ptr.*);
                allocator.free(entry.value_ptr.*);
            }
            env_map.deinit();
        }
    }
};

// Global settings for the task runner - similar to setting variables
// at the top of a Rakefile, but with explicit types and defaults
pub const Settings = struct {
    shell: []const u8 = "/bin/sh",
    workdir: []const u8 = ".",
    confirm_destructive: bool = true,

    pub fn deinit(self: *Settings, allocator: std.mem.Allocator) void {
        // In this simple version, settings are string literals
        // so we don't need to free them, but this pattern lets
        // us extend with dynamically allocated strings later
        _ = self;
        _ = allocator;
    }
};

// The main configuration structure - this replaces the implicit
// structure of a Rakefile with an explicit data model
pub const Config = struct {
    tasks: std.StringHashMap(Task),
    settings: Settings,
    allocator: std.mem.Allocator,

    // Initialize a new empty configuration
    pub fn init(allocator: std.mem.Allocator) Config {
        return Config{
            .tasks = std.StringHashMap(Task).init(allocator),
            .settings = Settings{},
            .allocator = allocator,
        };
    }

    // Clean up all allocated memory - this is the explicit version
    // of what Ruby's garbage collector does automatically
    pub fn deinit(self: *Config) void {
        var task_iterator = self.tasks.iterator();
        while (task_iterator.next()) |entry| {
            // Free the task name (key)
            self.allocator.free(entry.key_ptr.*);
            // Clean up the task itself
            entry.value_ptr.deinit(self.allocator);
        }
        self.tasks.deinit();
        self.settings.deinit(self.allocator);
    }

    // Get a task by name - similar to accessing a hash in Ruby
    // but with explicit error handling for missing keys
    pub fn getTask(self: *const Config, name: []const u8) ?*const Task {
        return self.tasks.getPtr(name);
    }

    // Add a new task to the configuration
    pub fn addTask(self: *Config, name: []const u8, task: Task) !void {
        // Duplicate the name string so we own the memory
        const owned_name = try self.allocator.dupe(u8, name);
        try self.tasks.put(owned_name, task);
    }
};

// Load configuration from a YAML file - this is more complex than
// Ruby's YAML.load because we need to parse the structure explicitly
// and handle memory allocation carefully
pub fn loadConfig(allocator: std.mem.Allocator) !Config {
    var config = Config.init(allocator);

    // Read the configuration file - explicit file handling instead
    // of Ruby's automatic file reading with blocks
    const file_content = std.fs.cwd().readFileAlloc(allocator, "cmdfile.yaml", 1024 * 1024 // 1MB max file size
    ) catch |err| switch (err) {
        error.FileNotFound => return error.FileNotFound,
        else => return err,
    };
    defer allocator.free(file_content);

    // Parse the YAML content - for now we'll implement a simple parser
    // In a full implementation, you'd use a YAML library, but this
    // shows the principles of explicit parsing in Zig
    try parseYamlConfig(&config, file_content);

    return config;
}

// Simple YAML parser for our specific format - this is much more
// explicit than Ruby's YAML library, but gives us full control
// over parsing and memory allocation
fn parseYamlConfig(config: *Config, content: []const u8) !void {
    var lines = std.mem.splitSequence(u8, content, "\n");
    var current_section: ?[]const u8 = null;
    var current_task_name: ?[]const u8 = null;
    var current_task: ?Task = null;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");

        // Skip empty lines and comments
        if (trimmed.len == 0 or trimmed[0] == '#') continue;

        // Detect sections (tasks:, settings:)
        if (std.mem.endsWith(u8, trimmed, ":") and !std.mem.startsWith(u8, trimmed, " ")) {
            // Save any pending task before switching sections
            if (current_task_name != null and current_task != null) {
                try config.addTask(current_task_name.?, current_task.?);
                current_task_name = null;
                current_task = null;
            }

            current_section = trimmed[0 .. trimmed.len - 1]; // Remove the ':'
            continue;
        }

        // Parse task definitions
        if (current_section != null and std.mem.eql(u8, current_section.?, "tasks")) {
            if (std.mem.startsWith(u8, trimmed, "  ") and std.mem.endsWith(u8, trimmed, ":")) {
                // Save previous task if exists
                if (current_task_name != null and current_task != null) {
                    try config.addTask(current_task_name.?, current_task.?);
                }

                // Start new task
                const task_name = std.mem.trim(u8, trimmed[2 .. trimmed.len - 1], " ");
                current_task_name = task_name;
                current_task = Task{ .command = "" }; // Will be set by command: line
                continue;
            }

            // Parse task properties
            if (current_task != null and std.mem.startsWith(u8, trimmed, "    ")) {
                const property_line = trimmed[4..]; // Remove indentation

                if (std.mem.startsWith(u8, property_line, "description:")) {
                    const desc_start = std.mem.indexOf(u8, property_line, "\"");
                    if (desc_start != null) {
                        const desc_end = std.mem.lastIndexOf(u8, property_line, "\"");
                        if (desc_end != null and desc_end.? > desc_start.?) {
                            const description = property_line[desc_start.? + 1 .. desc_end.?];
                            current_task.?.description = try config.allocator.dupe(u8, description);
                        }
                    }
                } else if (std.mem.startsWith(u8, property_line, "command:")) {
                    const cmd_start = std.mem.indexOf(u8, property_line, "\"");
                    if (cmd_start != null) {
                        const cmd_end = std.mem.lastIndexOf(u8, property_line, "\"");
                        if (cmd_end != null and cmd_end.? > cmd_start.?) {
                            const command = property_line[cmd_start.? + 1 .. cmd_end.?];
                            current_task.?.command = try config.allocator.dupe(u8, command);
                        }
                    }
                } else if (std.mem.startsWith(u8, property_line, "confirm:")) {
                    const value = std.mem.trim(u8, property_line[8..], " ");
                    current_task.?.confirm = std.mem.eql(u8, value, "true");
                }
            }
        }

        // Parse global settings
        if (current_section != null and std.mem.eql(u8, current_section.?, "settings")) {
            if (std.mem.startsWith(u8, trimmed, "  ")) {
                const setting_line = trimmed[2..];

                if (std.mem.startsWith(u8, setting_line, "shell:")) {
                    const shell_start = std.mem.indexOf(u8, setting_line, "\"");
                    if (shell_start != null) {
                        const shell_end = std.mem.lastIndexOf(u8, setting_line, "\"");
                        if (shell_end != null and shell_end.? > shell_start.?) {
                            const shell = setting_line[shell_start.? + 1 .. shell_end.?];
                            config.settings.shell = try config.allocator.dupe(u8, shell);
                        }
                    }
                } else if (std.mem.startsWith(u8, setting_line, "workdir:")) {
                    const workdir_start = std.mem.indexOf(u8, setting_line, "\"");
                    if (workdir_start != null) {
                        const workdir_end = std.mem.lastIndexOf(u8, setting_line, "\"");
                        if (workdir_end != null and workdir_end.? > workdir_start.?) {
                            const workdir = setting_line[workdir_start.? + 1 .. workdir_end.?];
                            config.settings.workdir = try config.allocator.dupe(u8, workdir);
                        }
                    }
                }
            }
        }
    }

    // Don't forget to save the last task
    if (current_task_name != null and current_task != null) {
        try config.addTask(current_task_name.?, current_task.?);
    }
}

// Validation function to ensure the configuration makes sense
// This is like having validations in a Ruby class, but explicit
pub fn validateConfig(config: *const Config) !void {
    if (config.tasks.count() == 0) {
        return error.NoTasksDefined;
    }

    // Check that all tasks have valid commands
    var task_iterator = config.tasks.iterator();
    while (task_iterator.next()) |entry| {
        const task = entry.value_ptr.*;
        if (task.command.len == 0) {
            return error.EmptyTaskCommand;
        }
    }
}

// Tests for the configuration module
test "config initialization" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var config = Config.init(allocator);
    defer config.deinit();

    try testing.expect(config.tasks.count() == 0);
    try testing.expect(std.mem.eql(u8, config.settings.shell, "/bin/sh"));
}

test "add and get task" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var config = Config.init(allocator);
    defer config.deinit();

    const task = Task{
        .command = "echo 'test'",
        .description = "Test task",
    };

    try config.addTask("test", task);

    const retrieved_task = config.getTask("test");
    try testing.expect(retrieved_task != null);
    try testing.expect(std.mem.eql(u8, retrieved_task.?.command, "echo 'test'"));
}
