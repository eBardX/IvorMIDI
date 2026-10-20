// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct BinaryIntegerMIDITests {
}

// MARK: -

extension BinaryIntegerMIDITests {
    @Test
    func clamped() {
        #expect((-1).clamped(to: 0...127) == 0)
        #expect(0.clamped(to: 0...127) == 0)
        #expect(64.clamped(to: 0...127) == 64)
        #expect(127.clamped(to: 0...127) == 127)
        #expect(128.clamped(to: 0...127) == 127)
        #expect(Int.min.clamped(to: -8_192...8_191) == -8_192)
        #expect(UInt.max.clamped(to: -8_192...8_191) == 8_191)
        #expect(UInt8(255).clamped(to: 0...127) == 127)
        #expect(Int8(-128).clamped(to: 0...127) == 0)
    }
}
