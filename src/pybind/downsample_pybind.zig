const std = @import("std");
const python = @cImport({
    @cDefine("Py_LIMITED_API", "3");
    @cInclude("Python.h");
});

pub const downsample = @import("downsample.zig").downsample;

pub fn downsample_pybind(_: [*c]python.PyObject, args: [*c]python.PyObject) callconv(.C) ?*python.PyObject {
    // parse inputs
    var iBufferPython: [*c]python.PyObject = null;
    var numDescriptions: usize = 0;
    if (python.PyArg_ParseTuple(
        args,
        "On",
        &iBufferPython,
        &numDescriptions,
    ) == 0) {
        return null;
    }

    if (python.PyList_Check(iBufferPython) == 0) {
        return python.PyErr_Format(python.PyExc_TypeError, "First argument should be a list.");
    }

    // infer buffer sizes
    const iBufferSize: usize = @intCast(python.PyList_Size(iBufferPython));
    const oBufferSize: usize = @intCast(iBufferSize / numDescriptions);

    // allocate internal types
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var iBuffer: []f64 = undefined;
    var oBuffer: []f64 = undefined;

    if (allocator.alloc(f64, iBufferSize)) |value| {
        iBuffer = value;
    } else |_| {
        return python.PyErr_Format(python.PyExc_ValueError, "Failed to allocate internally.");
    }
    if (allocator.alloc(f64, oBufferSize)) |value| {
        oBuffer = value;
    } else |_| {
        return python.PyErr_Format(python.PyExc_TypeError, "Failed to allocate internally.");
    }

    // deep copy input + run + deep copy output
    for (0..iBuffer.len) |index| {
        iBuffer[index] = python.PyFloat_AsDouble(python.PyList_GetItem(iBufferPython, @intCast(index)));
    }

    downsample(iBuffer, oBuffer, numDescriptions);

    var oBufferPython = python.PyList_New(@intCast(oBufferSize));
    for (0..oBuffer.len) |index| {
        if (python.PyList_SetItem(oBufferPython, @intCast(index), python.PyFloat_FromDouble(oBuffer[index])) != 0) {
            return python.PyErr_Format(python.PyExc_ValueError, "Failed to copy internal value into python list.");
        }
    }

    // return
    return oBufferPython;
}
