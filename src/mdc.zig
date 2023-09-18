const python = @cImport({
    @cDefine("Py_LIMITED_API", "3");
    @cInclude("Python.h");
});

// TODO:
// * finalize upsampler
// * finalize downsampler
// * arithmatic coder
// * arithmatic decoder
// * entropy coder
// * entropy decoder
// * dpcm coder
// * dpcm decoder
// * interleaver
// * deinterleaver
// * gain encoder
// * gain decoder
// * noise shaping filter

pub const module = @import("pybind.zig");
pub export fn PyInit_mdc() callconv(.C) [*c]python.PyObject {
    return python.PyModule_Create(&module.module);
}
