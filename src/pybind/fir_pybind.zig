const std = @import("std");
const python = @cImport({
    @cDefine("Py_LIMITED_API", "3");
    @cInclude("Python.h");
});

pub const fir = @import("fir.zig").fir;

pub fn fir_pybind(_: [*c]python.PyObject, args: [*c]python.PyObject) callconv(.C) ?*python.PyObject {
    // parse inputs
    var iBufferPython: [*c]python.PyObject = null;
    var coefficientsPython: [*c]python.PyObject = null;
    var statePython: [*c]python.PyObject = null;

    if (python.PyArg_ParseTuple(
        args,
        "OOO",
        &iBufferPython,
        &coefficientsPython,
        &statePython,
    ) == 0) {
        return null;
    }

    if (python.PyList_Check(iBufferPython) == 0) {
        return python.PyErr_Format(python.PyExc_TypeError, "First argument should be a list.");
    }
    if (python.PyList_Check(coefficientsPython) == 0) {
        return python.PyErr_Format(python.PyExc_TypeError, "Second argument should be a list.");
    }
    if (python.PyList_Check(statePython) == 0) {
        return python.PyErr_Format(python.PyExc_TypeError, "Third argument should be a list.");
    }

    // infer buffer sizes
    const iBufferSize: usize = @intCast(python.PyList_Size(iBufferPython));
    const coefficientsSize: usize = @intCast(python.PyList_Size(coefficientsPython));
    const stateSize: usize = @intCast(python.PyList_Size(statePython));
    const oBufferSize: usize = iBufferSize;

    if (stateSize != (coefficientsSize - 1)) {
        return python.PyErr_Format(python.PyExc_TypeError, "Invalid state size");
    }

    // allocate internal types
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var iBuffer: []f64 = undefined;
    var oBuffer: []f64 = undefined;
    var coefficients: []f64 = undefined;
    var state: []f64 = undefined;

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
    if (allocator.alloc(f64, coefficientsSize)) |value| {
        coefficients = value;
    } else |_| {
        return python.PyErr_Format(python.PyExc_ValueError, "Failed to allocate internally.");
    }
    if (allocator.alloc(f64, stateSize)) |value| {
        state = value;
    } else |_| {
        return python.PyErr_Format(python.PyExc_TypeError, "Failed to allocate internally.");
    }

    // deep copy input + run + deep copy output
    for (0..iBuffer.len) |index| {
        iBuffer[index] = python.PyFloat_AsDouble(
            python.PyList_GetItem(iBufferPython, @intCast(index)),
        );
    }
    for (0..coefficients.len) |index| {
        coefficients[index] = python.PyFloat_AsDouble(
            python.PyList_GetItem(coefficientsPython, @intCast(index)),
        );
    }
    for (0..state.len) |index| {
        state[index] = python.PyFloat_AsDouble(
            python.PyList_GetItem(statePython, @intCast(index)),
        );
    }

    fir(iBuffer, oBuffer, coefficients, state);

    var oBufferPython = python.PyList_New(@intCast(oBufferSize));
    for (0..oBuffer.len) |index| {
        if (python.PyList_SetItem(
            oBufferPython,
            @intCast(index),
            python.PyFloat_FromDouble(oBuffer[index]),
        ) != 0) {
            return python.PyErr_Format(
                python.PyExc_ValueError,
                "Failed to copy internal value into python list.",
            );
        }
    }
    var ostatePython = python.PyList_New(@intCast(stateSize));
    for (0..state.len) |index| {
        if (python.PyList_SetItem(
            ostatePython,
            @intCast(index),
            python.PyFloat_FromDouble(state[index]),
        ) != 0) {
            return python.PyErr_Format(
                python.PyExc_ValueError,
                "Failed to copy internal value into python list.",
            );
        }
    }

    // return
    return python.Py_BuildValue("(OO)", oBufferPython, ostatePython);
}
