// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIProgramTests {
}

// MARK: -

extension MIDIProgramTests {
    @Test
    func bytesValue() {
        #expect(MIDIProgram(uintValue: 1)?.bytesValue == [0x00])
        #expect(MIDIProgram(uintValue: 10)?.bytesValue == [0x09])
        #expect(MIDIProgram(uintValue: 128)?.bytesValue == [0x7f])
    }

    @Test
    func codable() throws {
        let original: MIDIProgram = 41
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIProgram.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("0".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDIProgram.self,
                                     from: data)
        }
    }

    @Test
    func comparable() {
        let low: MIDIProgram = 1
        let high: MIDIProgram = 128

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func description() {
        let value: MIDIProgram = 41

        #expect(value.description == "41")
    }

    @Test
    func equality() {
        let value1: MIDIProgram = 41
        let value2: MIDIProgram = 41
        let value3: MIDIProgram = 42

        #expect(value1 == value2)
        #expect(value1 != value3)
    }

    @Test
    func hashable() {
        let set: Set<MIDIProgram> = [41, 41, 42]

        #expect(set.count == 2)
    }

    @Test
    func init_bytesValue() {
        #expect(MIDIProgram(bytesValue: [0x00])?.uintValue == 1)
        #expect(MIDIProgram(bytesValue: [0x09])?.uintValue == 10)
        #expect(MIDIProgram(bytesValue: [0x7f])?.uintValue == 128)
    }

    @Test
    func init_bytesValue_invalid() {
        #expect(MIDIProgram(bytesValue: []) == nil)
        #expect(MIDIProgram(bytesValue: [0x00, 0x01]) == nil)
        #expect(MIDIProgram(bytesValue: [0x80]) == nil)
    }

    @Test
    func init_clamping() {
        #expect(MIDIProgram(clamping: 0).uintValue == 1)
        #expect(MIDIProgram(clamping: 1).uintValue == 1)
        #expect(MIDIProgram(clamping: 64).uintValue == 64)
        #expect(MIDIProgram(clamping: 128).uintValue == 128)
        #expect(MIDIProgram(clamping: 129).uintValue == 128)
        #expect(MIDIProgram(clamping: Int.min).uintValue == 1)
        #expect(MIDIProgram(clamping: UInt.max).uintValue == 128)
    }

    @Test
    func init_integerLiteral() {
        let value: MIDIProgram = 41

        #expect(value.uintValue == 41)
    }

    @Test
    func init_uintValue() {
        #expect(MIDIProgram(uintValue: 1)?.uintValue == 1)
        #expect(MIDIProgram(uintValue: 128)?.uintValue == 128)
    }

    @Test
    func init_uintValue_invalid() {
        #expect(MIDIProgram(uintValue: 0) == nil)
        #expect(MIDIProgram(uintValue: 129) == nil)
    }

    @Test
    func isValid() {
        #expect(!MIDIProgram.isValid(0))
        #expect(MIDIProgram.isValid(1))
        #expect(MIDIProgram.isValid(128))
        #expect(!MIDIProgram.isValid(129))
    }
}
