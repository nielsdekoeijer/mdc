const python = @cImport({
    @cDefine("Py_LIMITED_API", "3");
    @cInclude("Python.h");
});

pub const upsample_pybind = @import("upsample_pybind.zig").upsample_pybind;
pub const downsample_pybind = @import("downsample_pybind.zig").downsample_pybind;
pub var methods = [_]python.PyMethodDef{
    python.PyMethodDef{
        .ml_name = "upsample",
        .ml_meth = upsample_pybind,
        .ml_flags = python.METH_VARARGS,
        .ml_doc = "upsample a buffer",
    },
    python.PyMethodDef{
        .ml_name = "downsample",
        .ml_meth = downsample_pybind,
        .ml_flags = python.METH_VARARGS,
        .ml_doc = "downsample a buffer",
    },
    python.PyMethodDef{
        .ml_name = null,
        .ml_meth = null,
        .ml_flags = 0,
        .ml_doc = null,
    },
};

pub var module = python.PyModuleDef{
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
