// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIData2ValueTests {
}

// MARK: -

extension MIDIData2ValueTests {
    @Test
    func bytesValue() {
        #expect(MIDIData2Value(uintValue: 0)?.bytesValue == [0x00, 0x00])
        #expect(MIDIData2Value(uintValue: 128)?.bytesValue == [0x00, 0x01])
        #expect(MIDIData2Value(uintValue: 16_383)?.bytesValue == [0x7f, 0x7f])
    }

    @Test
    func codable() throws {
        let original: MIDIData2Value = 128
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIData2Value.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("16384".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDIData2Value.self,
                                     from: data)
        }
    }

    @Test
    func comparable() {
        let low: MIDIData2Value = 128
        let high: MIDIData2Value = 8_192

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func description() {
        let value: MIDIData2Value = 128

        #expect(value.description == "128")
    }

    @Test
    func equality() {
        let value1: MIDIData2Value = 128
        let value2: MIDIData2Value = 128
        let value3: MIDIData2Value = 8_192

        #expect(value1 == value2)
        #expect(value1 != value3)
    }

    @Test
    func hashable() {
        let set: Set<MIDIData2Value> = [128, 128, 8_192]

        #expect(set.count == 2)
    }

    @Test
    func init_bytesValue() {
        let value = MIDIData2Value(bytesValue: [0x00, 0x40])

        #expect(value != nil)
        #expect(value?.uintValue == 8_192)
    }

    @Test
    func init_bytesValue_invalidCount() {
        #expect(MIDIData2Value(bytesValue: []) == nil)
        #expect(MIDIData2Value(bytesValue: [0x00]) == nil)
        #expect(MIDIData2Value(bytesValue: [0x00, 0x00, 0x00]) == nil)
    }

    @Test
    func init_integerLiteral() {
        let value: MIDIData2Value = 128

        #expect(value.uintValue == 128)
    }

    @Test
    func init_uintValue() {
        #expect(MIDIData2Value(uintValue: 0) != nil)
        #expect(MIDIData2Value(uintValue: 8_192) != nil)
        #expect(MIDIData2Value(uintValue: 16_383) != nil)
    }

    @Test
    func init_uintValue_invalid() {
        #expect(MIDIData2Value(uintValue: 16_384) == nil)
    }

    @Test
    func isValid() {
        #expect(MIDIData2Value.isValid(0))
        #expect(MIDIData2Value.isValid(8_192))
        #expect(MIDIData2Value.isValid(16_383))
        #expect(!MIDIData2Value.isValid(16_384))
    }

    @Test
    func roundTrip() {
        let value = MIDIData2Value(uintValue: 8_192)

        #expect(value != nil)

        let bytes = value?.bytesValue

        #expect(bytes != nil)

        let roundTripped = bytes.flatMap { MIDIData2Value(bytesValue: $0) }

        #expect(roundTripped?.uintValue == 8_192)
    }
}
