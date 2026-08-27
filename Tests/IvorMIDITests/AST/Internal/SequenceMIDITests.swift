// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SequenceMIDITests {
}

// MARK: -

extension SequenceMIDITests {
    @Test
    func hex_multipleBytes() {
        let bytes: [UInt8] = [0x00, 0x0a, 0xff]

        #expect(bytes.hex == "00 0A FF")
    }

    @Test
    func hex_noBytes() {
        let bytes: [UInt8] = []

        #expect(bytes.hex.isEmpty)
    }

    @Test
    func hex_singleByte() {
        let bytes: [UInt8] = [0x42]

        #expect(bytes.hex == "42")
    }
}
