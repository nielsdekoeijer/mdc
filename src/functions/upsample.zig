pub fn upsample(iBuffer: []const f64, oBuffer: []f64, factor: usize) void {
    for (0..iBuffer.len) |index| {
        oBuffer[index * factor] = iBuffer[index];
    }
}
