const std = @import("std");

// This is like your Rakefile and gemspec combined into one file.
// Zig's build system is compile-time evaluated, meaning this code
// runs during compilation to determine how to build your project.
pub fn build(b: *std.Build) void {
    // Target and optimization settings - think of this as setting
    // Ruby version and environment variables, but for compilation
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Define the main executable - this is like specifying your
    // bin script in a gemspec, but with much more control
    const exe = b.addExecutable(.{
        .name = "cmdfile",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Install the executable so it can be run
    // Similar to how 'gem install' makes a command available
    b.installArtifact(exe);

    // Create a run step for easy testing during development
    // This is like having a 'rake run' task
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    // Allow passing command line arguments to our program
    // when running with 'zig build run -- <args>'
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Create a named step for running the application
    const run_step = b.step("run", "Run the cmdfile application");
    run_step.dependOn(&run_cmd.step);

    // Set up testing - Zig has built-in test support, no need for RSpec or minitest
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Create a test step that can be run with 'zig build test'
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    // Add individual test files - this lets us run specific test suites
    const test_files = [_][]const u8{
        "test/cli_test.zig",
        "test/config_test.zig",
        "test/task_runner_test.zig",
    };

    for (test_files) |test_file| {
        const test_exe = b.addTest(.{
            .root_source_file = b.path(test_file),
            .target = target,
            .optimize = optimize,
        });

        const test_run = b.addRunArtifact(test_exe);
        test_step.dependOn(&test_run.step);
    }

    // Create a clean step for removing build artifacts
    // Similar to 'rake clean' in your Ruby projects
    const clean_step = b.step("clean", "Remove build artifacts");
    const clean_cmd = b.addSystemCommand(&[_][]const u8{ "rm", "-rf", "zig-out", "zig-cache" });
    clean_step.dependOn(&clean_cmd.step);
}
