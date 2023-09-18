const downsample = @import("downsample.zig").downsample;
const fir = @import("fir.zig").fir;

pub fn filteredDownsample(iBuffer: []const f64, mBuffer: []f64, oBuffer: []f64, coefficients: []f64, state: []f64, factor: usize) void {
    fir(iBuffer, mBuffer, coefficients, state);
    downsample(mBuffer, oBuffer, factor);
}
