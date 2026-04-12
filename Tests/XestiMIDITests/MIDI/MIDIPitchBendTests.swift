// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDIPitchBendTests {
}

// MARK: -

extension MIDIPitchBendTests {
    @Test
    func test_bytesValue() {
        #expect(MIDIPitchBend(intValue: 0)?.bytesValue == [0x00, 0x40])
        #expect(MIDIPitchBend(intValue: -8_192)?.bytesValue == [0x00, 0x00])
        #expect(MIDIPitchBend(intValue: 8_191)?.bytesValue == [0x7F, 0x7F])
    }

    @Test
    func test_init_bytesValue() {
        let center = MIDIPitchBend(bytesValue: [0x00, 0x40])

        #expect(center != nil)
        #expect(center?.intValue == 0)

        let min = MIDIPitchBend(bytesValue: [0x00, 0x00])

        #expect(min != nil)
        #expect(min?.intValue == -8_192)

        let max = MIDIPitchBend(bytesValue: [0x7F, 0x7F])

        #expect(max != nil)
        #expect(max?.intValue == 8_191)
    }

    @Test
    func test_init_bytesValue_invalidCount() {
        #expect(MIDIPitchBend(bytesValue: []) == nil)
        #expect(MIDIPitchBend(bytesValue: [0x00]) == nil)
        #expect(MIDIPitchBend(bytesValue: [0x00, 0x00, 0x00]) == nil)
    }

    @Test
    func test_init_intValue() {
        #expect(MIDIPitchBend(intValue: 0) != nil)
        #expect(MIDIPitchBend(intValue: -8_192) != nil)
        #expect(MIDIPitchBend(intValue: 8_191) != nil)
    }

    @Test
    func test_init_intValue_invalid() {
        #expect(MIDIPitchBend(intValue: -8_193) == nil)
        #expect(MIDIPitchBend(intValue: 8_192) == nil)
    }

    @Test
    func test_isValid() {
        #expect(!MIDIPitchBend.isValid(-8_193))
        #expect(MIDIPitchBend.isValid(-8_192))
        #expect(MIDIPitchBend.isValid(0))
        #expect(MIDIPitchBend.isValid(8_191))
        #expect(!MIDIPitchBend.isValid(8_192))
    }

    @Test
    func test_roundTrip() {
        let value = MIDIPitchBend(intValue: -1_234)

        #expect(value != nil)

        let bytes = value?.bytesValue

        #expect(bytes != nil)

        let roundTripped = bytes.flatMap { MIDIPitchBend(bytesValue: $0) }

        #expect(roundTripped?.intValue == -1_234)
    }
}
