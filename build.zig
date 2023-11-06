const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libyasm_stdint = b.addWriteFile("libyasm-stdint.h", libyasm_stdint_data);
    const license_c = b.addWriteFile("license.c", license_data);

    const libyasm = b.addStaticLibrary(.{
        .name = "yasm",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    libyasm.addIncludePath(.{ .path = "." });
    libyasm.addCSourceFiles(.{ .files = libyasm_srsc, .flags = &.{"-fno-sanitize=undefined"} });
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
        // Name of package
        .PACKAGE = "yasm",
        // Define to the address where bug reports for this package should be sent.
        .PACKAGE_BUGREPORT = "bug-yasm@tortall.net",
        // Define to the full name of this package.
        .PACKAGE_NAME = "yasm",
        // Define to the full name and version of this package.
        .PACKAGE_STRING = "@PACKAGE_STRING@",

        // // Define to the version of this package.
        // .PACKAGE_VERSION = "@PACKAGE_VERSION@",
        // .VERSION = PACKAGE_VERSION,
    });
    libyasm.addConfigHeader(config_h);
    inline for (libyasm_headers) |h| libyasm.installHeader(h, h);
    // b.installArtifact(libyasm);

    const yasm_exe = b.addExecutable(.{
        .name = "yasm",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    yasm_exe.addIncludePath(.{ .path = "." });
    yasm_exe.addIncludePath(.{ .path = "frontends/yasm" });
    yasm_exe.addIncludePath(libyasm_stdint.getDirectory());
    yasm_exe.addIncludePath(license_c.getDirectory());
    yasm_exe.addCSourceFiles(.{ .files = &.{ "frontends/yasm/yasm.c", "frontends/yasm/yasm-options.c" }, .flags = &.{"-fno-sanitize=undefined"} });
    yasm_exe.defineCMacro("HAVE_CONFIG_H", null);
    yasm_exe.addConfigHeader(config_h);
    yasm_exe.linkLibrary(libyasm);
    b.installArtifact(yasm_exe);
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

const license_data =
    \\static const char *license_msg[] = {
    \\    "Yasm is Copyright (c) 2001-2014 Peter Johnson and other Yasm developers.",
    \\    "",
    \\    "Yasm developers and/or contributors include:",
    \\    "  Peter Johnson",
    \\    "  Michael Urman",
    \\    "  Brian Gladman (Visual Studio build files, other fixes)",
    \\    "  Stanislav Karchebny (options parser)",
    \\    "  Mathieu Monnier (SSE4 instruction patches, NASM preprocessor additions)",
    \\    "  Anonymous \"NASM64\" developer (NASM preprocessor fixes)",
    \\    "  Stephen Polkowski (x86 instruction patches)",
    \\    "  Henryk Richter (Mach-O object format)",
    \\    "  Ben Skeggs (patches, bug reports)",
    \\    "  Alexei Svitkine (GAS preprocessor)",
    \\    "  Samuel Thibault (TASM parser and frontend)",
    \\    "",
    \\    "-----------------------------------",
    \\    "Yasm licensing overview and summary",
    \\    "-----------------------------------",
    \\    "",
    \\    "Note: This document does not provide legal advice nor is it the actual",
    \\    "license of any part of Yasm.  See the individual licenses for complete",
    \\    "details.  Consult a lawyer for legal advice.",
    \\    "",
    \\    "The primary license of Yasm is the 2-clause BSD license.  Please use this",
    \\    "license if you plan on submitting code to the project.",
    \\    "",
    \\    "Yasm has absolutely no warranty; not even for merchantibility or fitness",
    \\    "for a particular purpose.",
    \\    "",
    \\    "-------",
    \\    "Libyasm",
    \\    "-------",
    \\    "Libyasm is 2-clause or 3-clause BSD licensed, with the exception of",
    \\    "bitvect, which is triple-licensed under the Artistic license, GPL, and",
    \\    "LGPL.  Libyasm is thus GPL and LGPL compatible.  In addition, this also",
    \\    "means that libyasm is free for binary-only distribution as long as the",
    \\    "terms of the 3-clause BSD license and Artistic license (as it applies to",
    \\    "bitvect) are fulfilled.",
    \\    "",
    \\    "-------",
    \\    "Modules",
    \\    "-------",
    \\    "The modules are 2-clause or 3-clause BSD licensed.",
    \\    "",
    \\    "---------",
    \\    "Frontends",
    \\    "---------",
    \\    "The frontends are 2-clause BSD licensed.",
    \\    "",
    \\    "-------------",
    \\    "License Texts",
    \\    "-------------",
    \\    "The full text of all licenses are provided in separate files in the source",
    \\    "distribution.  Each source file may include the entire license (in the case",
    \\    "of the BSD and Artistic licenses), or may reference the GPL or LGPL license",
    \\    "file.",
    \\    "",
    \\    "BSD.txt - 2-clause and 3-clause BSD licenses",
    \\    "Artistic.txt - Artistic license",
    \\    "GNU_GPL-2.0 - GNU General Public License",
    \\    "GNU_LGPL-2.0 - GNU Library General Public License",
    \\};
;
