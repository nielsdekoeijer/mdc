pub fn downsample(iBuffer: []const f64, oBuffer: []f64, numDescriptions: usize) void {
    for (0..oBuffer.len) |index| {
        oBuffer[index] = iBuffer[index * numDescriptions];
    }
}
