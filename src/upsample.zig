pub fn upsample(iBuffer: []const f64, oBuffer: []f64, numDescriptions: usize) void {
    for (0..iBuffer.len) |index| {
        oBuffer[index * numDescriptions] = iBuffer[index];
    }
}
