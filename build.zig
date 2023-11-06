const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libyasm_stdint = b.addWriteFile("libyasm-stdint.h", libyasm_stdint_data);

    const libyasm = b.addStaticLibrary(.{
        .name = "yasm",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    libyasm.addIncludePath(.{ .path = "." });
    libyasm.addCSourceFiles(.{ .files = libyasm_srsc });
    libyasm.defineCMacro("YASM_LIB_SOURCE", null);
    libyasm.defineCMacro("HAVE_CONFIG_H", null);
    libyasm.addIncludePath(libyasm_stdint.getDirectory());
    const config_h = b.addConfigHeader(.{ .include_path = "config.h" }, .{
        // Define if shared libs are being built
        .BUILD_SHARED_LIBS = 0,
        // Define if messsage translations are enabled
        .ENABLE_NLS = 1,
        // Define if you have the `abort' function.
        .HAVE_ABORT = 1,
        // Define to 1 if you have the <libgen.h> header file.
        .HAVE_LIBGEN_H = 1,
        // Define to 1 if you have the <unistd.h> header file.
        .HAVE_UNISTD_H = 1,
        // Define to 1 if you have the <direct.h> header file.
        .HAVE_DIRECT_H = null,
        // Define to 1 if you have the `getcwd' function.
        .HAVE_GETCWD = 1,
        // Define to 1 if you have the `_stricmp' function.
        .HAVE__STRICMP = null,
        // Define to 1 if you have the `toascii' function.
        .HAVE_TOASCII = 1,
        //Name of package
        .PACKAGE = "yasm",
    });
    libyasm.addConfigHeader(config_h);
    inline for (libyasm_headers) |h| libyasm.installHeader(h, h);
    b.installArtifact(libyasm);
}

const StrSlice = []const []const u8;

const libyasm_srsc: StrSlice = &.{
    "libyasm/assocdat.c",
    "libyasm/bitvect.c",
    "libyasm/bc-align.c",
    "libyasm/bc-data.c",
    "libyasm/bc-incbin.c",
    "libyasm/bc-org.c",
    "libyasm/bc-reserve.c",
    "libyasm/bytecode.c",
    "libyasm/cmake-module.c",
    "libyasm/errwarn.c",
    "libyasm/expr.c",
    "libyasm/file.c",
    "libyasm/floatnum.c",
    "libyasm/hamt.c",
    "libyasm/insn.c",
    "libyasm/intnum.c",
    "libyasm/inttree.c",
    "libyasm/linemap.c",
    "libyasm/md5.c",
    "libyasm/mergesort.c",
    "libyasm/phash.c",
    "libyasm/section.c",
    "libyasm/strcasecmp.c",
    "libyasm/strsep.c",
    "libyasm/symrec.c",
    "libyasm/valparam.c",
    "libyasm/value.c",
    "libyasm/xmalloc.c",
    "libyasm/xstrdup.c",
};

const libyasm_headers: StrSlice = &.{
    "libyasm/arch.h",
    "libyasm/assocdat.h",
    "libyasm/bitvect.h",
    "libyasm/bytecode.h",
    "libyasm/compat-queue.h",
    "libyasm/coretype.h",
    "libyasm/dbgfmt.h",
    "libyasm/errwarn.h",
    "libyasm/expr.h",
    "libyasm/file.h",
    "libyasm/floatnum.h",
    "libyasm/hamt.h",
    "libyasm/insn.h",
    "libyasm/intnum.h",
    "libyasm/inttree.h",
    "libyasm/linemap.h",
    "libyasm/listfmt.h",
    "libyasm/md5.h",
    "libyasm/module.h",
    "libyasm/objfmt.h",
    "libyasm/parser.h",
    "libyasm/phash.h",
    "libyasm/preproc.h",
    "libyasm/section.h",
    "libyasm/symrec.h",
    "libyasm/valparam.h",
    "libyasm/value.h",
};

const libyasm_stdint_data =
    \\ #ifndef YASM_STDINT_H
    \\ #define YASM_STDINT_H
    \\
    \\ #include <stdint.h>
    \\
    \\ // no shared lib for now
    \\ // #ifndef BUILD_SHARED_LIBS
    \\ // #cmakedefine BUILD_SHARED_LIBS
    \\ // #define BUILD_SHARED_LIBS_UNDEF
    \\ // #endif
    \\
    \\ // #ifndef YASM_LIB_DECL
    \\ // # if defined(BUILD_SHARED_LIBS) && defined(_WIN32)
    \\ // #  ifdef YASM_LIB_SOURCE
    \\ // #   define YASM_LIB_DECL __declspec(dllexport)
    \\ // #  else
    \\ // #   define YASM_LIB_DECL __declspec(dllimport)
    \\ // #  endif
    \\ // # else
    \\ // #   define YASM_LIB_DECL
    \\ // # endif
    \\ // #endif
    \\
    \\ // #undef HAVE_STDINT_H
    \\ // #ifdef BUILD_SHARED_LIBS_UNDEF
    \\ // #undef BUILD_SHARED_LIBS
    \\ // #undef BUILD_SHARED_LIBS_UNDEF
    \\ // #endif
    \\
    \\ #endif
;
