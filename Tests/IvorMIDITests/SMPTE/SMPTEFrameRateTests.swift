// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMPTEFrameRateTests {
}

// MARK: -

extension SMPTEFrameRateTests {
    @Test
    func uintValue_fps24() {
        #expect(SMPTEFrameRate.fps24.uintValue == 24)
    }

    @Test
    func uintValue_fps25() {
        #expect(SMPTEFrameRate.fps25.uintValue == 25)
    }

    @Test
    func uintValue_fps2997() {
        #expect(SMPTEFrameRate.fps2997.uintValue == 30)
    }

    @Test
    func uintValue_fps30() {
        #expect(SMPTEFrameRate.fps30.uintValue == 30)
    }
}
