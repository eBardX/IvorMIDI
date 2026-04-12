// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFTempoTests {
}

// MARK: -

extension SMFTempoTests {
    @Test
    func test_bytesValue() {
        let tempo = SMFTempo(uintValue: 500_000)

        #expect(tempo?.bytesValue == [0x07, 0xA1, 0x20])
    }

    @Test
    func test_bytesValue_zero() {
        let tempo = SMFTempo(uintValue: 0)

        #expect(tempo?.bytesValue == [0x00, 0x00, 0x00])
    }

    @Test
    func test_init_bytesValue() {
        let tempo = SMFTempo(bytesValue: [0x07, 0xA1, 0x20])

        #expect(tempo != nil)
        #expect(tempo?.uintValue == 500_000)
    }

    @Test
    func test_init_bytesValue_invalidCount() {
        #expect(SMFTempo(bytesValue: []) == nil)
        #expect(SMFTempo(bytesValue: [0x00, 0x00]) == nil)
        #expect(SMFTempo(bytesValue: [0x00, 0x00, 0x00, 0x00]) == nil)
    }

    @Test
    func test_init_uintValue() {
        #expect(SMFTempo(uintValue: 0) != nil)
        #expect(SMFTempo(uintValue: 500_000) != nil)
        #expect(SMFTempo(uintValue: 16_777_215) != nil)
    }

    @Test
    func test_init_uintValue_invalid() {
        #expect(SMFTempo(uintValue: 16_777_216) == nil)
    }

    @Test
    func test_isValid() {
        #expect(SMFTempo.isValid(0))
        #expect(SMFTempo.isValid(500_000))
        #expect(SMFTempo.isValid(16_777_215))
        #expect(!SMFTempo.isValid(16_777_216))
    }

    @Test
    func test_roundTrip() {
        let tempo = SMFTempo(uintValue: 600_000)
        let bytes = tempo?.bytesValue

        #expect(bytes != nil)

        let roundTripped = bytes.flatMap { SMFTempo(bytesValue: $0) }

        #expect(roundTripped?.uintValue == 600_000)
    }
}
