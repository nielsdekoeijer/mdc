const upsample = @import("upsample.zig").upsample;
const fir = @import("fir.zig").fir;

pub fn filteredUpsample(iBuffer: []const f64, mBuffer: []f64, oBuffer: []f64, coefficients: []f64, state: []f64, factor: usize) void {
    upsample(iBuffer, mBuffer, factor);
    fir(mBuffer, oBuffer, coefficients, state);
}
