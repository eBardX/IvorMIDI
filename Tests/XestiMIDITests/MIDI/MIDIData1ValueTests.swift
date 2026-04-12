// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDIData1ValueTests {
}

// MARK: -

extension MIDIData1ValueTests {
    @Test
    func test_bytesValue() {
        #expect(MIDIData1Value(uintValue: 0)?.bytesValue == [0x00])
        #expect(MIDIData1Value(uintValue: 64)?.bytesValue == [0x40])
        #expect(MIDIData1Value(uintValue: 127)?.bytesValue == [0x7F])
    }

    @Test
    func test_init_bytesValue() {
        let value = MIDIData1Value(bytesValue: [0x3C])

        #expect(value != nil)
        #expect(value?.uintValue == 60)
    }

    @Test
    func test_init_bytesValue_invalidCount() {
        #expect(MIDIData1Value(bytesValue: []) == nil)
        #expect(MIDIData1Value(bytesValue: [0x00, 0x01]) == nil)
    }

    @Test
    func test_init_uintValue() {
        #expect(MIDIData1Value(uintValue: 0) != nil)
        #expect(MIDIData1Value(uintValue: 127) != nil)
    }

    @Test
    func test_init_uintValue_invalid() {
        #expect(MIDIData1Value(uintValue: 128) == nil)
    }

    @Test
    func test_isValid() {
        #expect(MIDIData1Value.isValid(0))
        #expect(MIDIData1Value.isValid(64))
        #expect(MIDIData1Value.isValid(127))
        #expect(!MIDIData1Value.isValid(128))
    }
}
