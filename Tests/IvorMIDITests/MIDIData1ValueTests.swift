// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIData1ValueTests {
}

// MARK: -

extension MIDIData1ValueTests {
    @Test
    func bytesValue() {
        #expect(MIDIData1Value(uintValue: 0)?.bytesValue == [0x00])
        #expect(MIDIData1Value(uintValue: 64)?.bytesValue == [0x40])
        #expect(MIDIData1Value(uintValue: 127)?.bytesValue == [0x7f])
    }

    @Test
    func codable() throws {
        let original: MIDIData1Value = 60
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIData1Value.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("128".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDIData1Value.self,
                                     from: data)
        }
    }

    @Test
    func comparable() {
        let low: MIDIData1Value = 60
        let high: MIDIData1Value = 100

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func description() {
        let value: MIDIData1Value = 60

        #expect(value.description == "60")
    }

    @Test
    func equality() {
        let value1: MIDIData1Value = 60
        let value2: MIDIData1Value = 60
        let value3: MIDIData1Value = 100

        #expect(value1 == value2)
        #expect(value1 != value3)
    }

    @Test
    func hashable() {
        let set: Set<MIDIData1Value> = [60, 60, 100]

        #expect(set.count == 2)
    }

    @Test
    func init_bytesValue() {
        let value = MIDIData1Value(bytesValue: [0x3c])

        #expect(value != nil)
        #expect(value?.uintValue == 60)
    }

    @Test
    func init_bytesValue_invalidCount() {
        #expect(MIDIData1Value(bytesValue: []) == nil)
        #expect(MIDIData1Value(bytesValue: [0x00, 0x01]) == nil)
    }

    @Test
    func init_integerLiteral() {
        let value: MIDIData1Value = 60

        #expect(value.uintValue == 60)
    }

    @Test
    func init_uintValue() {
        #expect(MIDIData1Value(uintValue: 0) != nil)
        #expect(MIDIData1Value(uintValue: 127) != nil)
    }

    @Test
    func init_uintValue_invalid() {
        #expect(MIDIData1Value(uintValue: 128) == nil)
    }

    @Test
    func isValid() {
        #expect(MIDIData1Value.isValid(0))
        #expect(MIDIData1Value.isValid(64))
        #expect(MIDIData1Value.isValid(127))
        #expect(!MIDIData1Value.isValid(128))
    }
}
