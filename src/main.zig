const std = @import("std");
const python = @cImport({
    @cDefine("Py_LIMITED_API", "3");
    @cInclude("Python.h");
});

// TODO:
// * finalize upsampler
// * downsampler
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

const upsample_pybind = @import("upsample_pybind.zig").upsample_pybind;
var methods = [_]python.PyMethodDef{
    python.PyMethodDef{
        .ml_name = "upsample",
        .ml_meth = upsample_pybind,
        .ml_flags = python.METH_VARARGS,
        .ml_doc = "upsample a buffer",
    },
};

var module = python.PyModuleDef{
    .m_base = python.PyModuleDef_Base{
        .ob_base = python.PyObject{
            .ob_refcnt = 1,
            .ob_type = null,
        },
        .m_init = null,
        .m_index = 0,
        .m_copy = null,
    },
    .m_name = "mdc",
    .m_doc = "mdc python",
    .m_size = -1,
    .m_methods = &methods,
    .m_slots = null,
    .m_traverse = null,
    .m_clear = null,
    .m_free = null,
};

pub export fn PyInit_mdc() callconv(.C) [*c]python.PyObject {
    return python.PyModule_Create(&module);
}
