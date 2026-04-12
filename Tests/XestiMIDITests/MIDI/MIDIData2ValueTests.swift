// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDIData2ValueTests {
}

// MARK: -

extension MIDIData2ValueTests {
    @Test
    func test_bytesValue() {
        #expect(MIDIData2Value(uintValue: 0)?.bytesValue == [0x00, 0x00])
        #expect(MIDIData2Value(uintValue: 128)?.bytesValue == [0x00, 0x01])
        #expect(MIDIData2Value(uintValue: 16_383)?.bytesValue == [0x7F, 0x7F])
    }

    @Test
    func test_init_bytesValue() {
        let value = MIDIData2Value(bytesValue: [0x00, 0x40])

        #expect(value != nil)
        #expect(value?.uintValue == 8_192)
    }

    @Test
    func test_init_bytesValue_invalidCount() {
        #expect(MIDIData2Value(bytesValue: []) == nil)
        #expect(MIDIData2Value(bytesValue: [0x00]) == nil)
        #expect(MIDIData2Value(bytesValue: [0x00, 0x00, 0x00]) == nil)
    }

    @Test
    func test_init_uintValue() {
        #expect(MIDIData2Value(uintValue: 0) != nil)
        #expect(MIDIData2Value(uintValue: 8_192) != nil)
        #expect(MIDIData2Value(uintValue: 16_383) != nil)
    }

    @Test
    func test_init_uintValue_invalid() {
        #expect(MIDIData2Value(uintValue: 16_384) == nil)
    }

    @Test
    func test_isValid() {
        #expect(MIDIData2Value.isValid(0))
        #expect(MIDIData2Value.isValid(8_192))
        #expect(MIDIData2Value.isValid(16_383))
        #expect(!MIDIData2Value.isValid(16_384))
    }

    @Test
    func test_roundTrip() {
        let value = MIDIData2Value(uintValue: 8_192)

        #expect(value != nil)

        let bytes = value?.bytesValue

        #expect(bytes != nil)

        let roundTripped = bytes.flatMap { MIDIData2Value(bytesValue: $0) }

        #expect(roundTripped?.uintValue == 8_192)
    }
}
