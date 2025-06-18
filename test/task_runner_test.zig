const std = @import("std");
const testing = std.testing;
const task_runner = @import("../src/task_runner.zig");

test "task runner initialization" {
    // Test task runner creation and initialization
    const allocator = testing.allocator;

    var runner = task_runner.TaskRunner.init(allocator);
    defer runner.deinit();

    try testing.expect(runner.tasks.items.len == 0);
}

test "task execution basic functionality" {
    // Test basic task execution
    const allocator = testing.allocator;

    var runner = task_runner.TaskRunner.init(allocator);
    defer runner.deinit();

    // Create a simple test task
    const test_task = task_runner.Task{
        .name = "test_task",
        .command = "echo 'test'",
        .description = "A test task",
        .dependencies = std.ArrayList([]const u8).init(allocator),
    };

    // Test task addition
    try runner.addTask(test_task);
    try testing.expect(runner.tasks.items.len == 1);
}

test "task dependency resolution" {
    // Test task dependency resolution
    const allocator = testing.allocator;

    var runner = task_runner.TaskRunner.init(allocator);
    defer runner.deinit();

    // Create tasks with dependencies
    var dep_list = std.ArrayList([]const u8).init(allocator);
    defer dep_list.deinit();
    try dep_list.append("dependency_task");

    const dependent_task = task_runner.Task{
        .name = "dependent_task",
        .command = "echo 'dependent'",
        .description = "A task with dependencies",
        .dependencies = dep_list,
    };

    const dependency_task = task_runner.Task{
        .name = "dependency_task",
        .command = "echo 'dependency'",
        .description = "A dependency task",
        .dependencies = std.ArrayList([]const u8).init(allocator),
    };

    // Test dependency resolution logic
    try runner.addTask(dependency_task);
    try runner.addTask(dependent_task);

    const execution_order = try runner.resolveDependencies("dependent_task");
    defer allocator.free(execution_order);

    try testing.expect(execution_order.len == 2);
}

test "task parallel execution" {
    // Test parallel task execution capabilities
    const allocator = testing.allocator;

    var runner = task_runner.TaskRunner.init(allocator);
    defer runner.deinit();

    // Create independent tasks that can run in parallel
    const task1 = task_runner.Task{
        .name = "parallel_task_1",
        .command = "sleep 0.1",
        .description = "First parallel task",
        .dependencies = std.ArrayList([]const u8).init(allocator),
    };

    const task2 = task_runner.Task{
        .name = "parallel_task_2",
        .command = "sleep 0.1",
        .description = "Second parallel task",
        .dependencies = std.ArrayList([]const u8).init(allocator),
    };

    try runner.addTask(task1);
    try runner.addTask(task2);

    // Test that parallel execution works
    const start_time = std.time.milliTimestamp();
    try runner.runTasksParallel(&[_][]const u8{ "parallel_task_1", "parallel_task_2" });
    const end_time = std.time.milliTimestamp();

    // Should complete in less time than sequential execution
    try testing.expect(end_time - start_time < 250); // Less than 0.25 seconds
}
