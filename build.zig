const std = @import("std");
const raySdk = @import("raylib/src/build.zig");

// setTarget() must have been called on step before calling this
// fn addRaylibDependencies(step: *std.build.LibExeObjStep, raylib: *std.build.LibExeObjStep) void {
//     step.addIncludePath(std.Build.LazyPath{ .path = "raylib/src/" });

//     // raylib's build.zig file specifies all libraries this executable must be
//     // linked with, so let's copy them from there.
//     for (raylib.link_objects.items) |o| {
//         if (o == .system_lib) {
//             step.linkSystemLibrary(o.system_lib.name);
//         }
//     }
//     if (step.target.isWindows()) {
//         step.addObjectFile(std.Build.LazyPath{ .path = "zig-out/lib/raylib.lib" });
//     } else {
//         step.addObjectFile(std.Build.LazyPath{ .path = "zig-out/lib/libraylib.a" });
//     }
// }

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const rloptions = raySdk.Options{
        .raudio = true,
        .rmodels = true,
        .rshapes = true,
        .rtext = true,
        .rtextures = true,
        .raygui = false,
        .platform_drm = false,
    };
    const optimize = b.standardOptimizeOption(.{});

    const raylib = try raySdk.addRaylib(b, target, optimize, rloptions);
    b.installArtifact(raylib);

    const exe = b.addExecutable(.{
        .name = "algorithms",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();

    // addRaylibDependencies(exe, raylib);
    exe.addIncludePath(.{ .path = "raylib/src" });
    exe.linkLibrary(raylib);

    b.installArtifact(exe);

    // exe.addIncludePath(.{ .path = "./raylib/src" });
    // exe.addObjectFile(.{ .path = "./raylib/src/libraylib.a" });

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    // addRaylibDependencies(unit_tests, raylib);

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
