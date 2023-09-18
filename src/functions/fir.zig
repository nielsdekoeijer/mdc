pub fn fir(iBuffer: []const f64, oBuffer: []f64, coefficients: []const f64, state: []f64) void {
    for (0..iBuffer.len) |n| {
        oBuffer[n] = state[0] + coefficients[0] * iBuffer[n];
        for (0..coefficients.len - 2) |m| {
            state[m] = state[m + 1] + coefficients[m + 1] * iBuffer[n];
        }

        state[coefficients.len - 2] = coefficients[coefficients.len - 1] * iBuffer[n];
    }
}
