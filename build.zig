const std = @import("std");
pub fn build(b: *std.Build) void {
    const lib = b.addSharedLibrary(.{
        .name = "mdc",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/mdc.zig" },
        .target = b.standardTargetOptions(.{}),
        .optimize = std.builtin.OptimizeMode.ReleaseFast,
    });
    lib.linkSystemLibrary("c");
    lib.addIncludePath(.{ .path = "/usr/include/python3.11/" });
    b.installArtifact(lib);
    const lib_install = b.addInstallFileWithDir(lib.getOutputSource(), .lib, "../../mdc.so");
    lib_install.step.dependOn(&lib.step);
    b.getInstallStep().dependOn(&lib_install.step);
}
