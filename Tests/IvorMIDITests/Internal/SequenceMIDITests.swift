// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SequenceMIDITests {
}

// MARK: -

extension SequenceMIDITests {
    @Test
    func tuningChecksum() {
        #expect(([] as [UInt8]).tuningChecksum == 0x00)
        #expect(([0x7e, 0x7f, 0x08, 0x04] as [UInt8]).tuningChecksum == 0x0d)
    }

    @Test
    func tuningChecksum_masksTopBit() {
        #expect(([0xf0, 0x0f] as [UInt8]).tuningChecksum == 0x7f)
    }

    @Test
    func tuningChecksum_slice() {
        let bytes: [UInt8] = [0x01, 0x02, 0x04]

        #expect(bytes.dropLast().tuningChecksum == 0x03)
    }
}
