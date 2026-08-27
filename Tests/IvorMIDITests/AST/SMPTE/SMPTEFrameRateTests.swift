// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMPTEFrameRateTests {
}

// MARK: -

extension SMPTEFrameRateTests {
    @Test
    func equality() {
        #expect(SMPTEFrameRate.fps24 == .fps24)
    }

    @Test
    func hashable() {
        let set: Set<SMPTEFrameRate> = [.fps30, .fps30, .fps2997]

        #expect(set.count == 2)
    }

    @Test
    func inequality_sameNominalRate() {
        #expect(SMPTEFrameRate.fps30 != .fps2997)
    }

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
