// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIPitchBendTests {
}

// MARK: -

extension MIDIPitchBendTests {
    @Test
    func bytesValue() {
        #expect(MIDIPitchBend(intValue: 0)?.bytesValue == [0x00, 0x40])
        #expect(MIDIPitchBend(intValue: -8_192)?.bytesValue == [0x00, 0x00])
        #expect(MIDIPitchBend(intValue: 8_191)?.bytesValue == [0x7f, 0x7f])
    }

    @Test
    func codable() throws {
        let original: MIDIPitchBend = -100
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIPitchBend.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("8192".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDIPitchBend.self,
                                     from: data)
        }
    }

    @Test
    func comparable() {
        let low: MIDIPitchBend = -100
        let high: MIDIPitchBend = 100

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func description() {
        let value: MIDIPitchBend = -100

        #expect(value.description == "-100")
    }

    @Test
    func equality() {
        let value1: MIDIPitchBend = -100
        let value2: MIDIPitchBend = -100
        let value3: MIDIPitchBend = 100

        #expect(value1 == value2)
        #expect(value1 != value3)
    }

    @Test
    func hashable() {
        let set: Set<MIDIPitchBend> = [-100, -100, 100]

        #expect(set.count == 2)
    }

    @Test
    func init_bytesValue() {
        let center = MIDIPitchBend(bytesValue: [0x00, 0x40])

        #expect(center != nil)
        #expect(center?.intValue == 0)

        let min = MIDIPitchBend(bytesValue: [0x00, 0x00])

        #expect(min != nil)
        #expect(min?.intValue == -8_192)

        let max = MIDIPitchBend(bytesValue: [0x7f, 0x7f])

        #expect(max != nil)
        #expect(max?.intValue == 8_191)
    }

    @Test
    func init_bytesValue_invalidCount() {
        #expect(MIDIPitchBend(bytesValue: []) == nil)
        #expect(MIDIPitchBend(bytesValue: [0x00]) == nil)
        #expect(MIDIPitchBend(bytesValue: [0x00, 0x00, 0x00]) == nil)
    }

    @Test
    func init_integerLiteral() {
        let value: MIDIPitchBend = -100

        #expect(value.intValue == -100)
    }

    @Test
    func init_intValue() {
        #expect(MIDIPitchBend(intValue: 0) != nil)
        #expect(MIDIPitchBend(intValue: -8_192) != nil)
        #expect(MIDIPitchBend(intValue: 8_191) != nil)
    }

    @Test
    func init_intValue_invalid() {
        #expect(MIDIPitchBend(intValue: -8_193) == nil)
        #expect(MIDIPitchBend(intValue: 8_192) == nil)
    }

    @Test
    func isValid() {
        #expect(!MIDIPitchBend.isValid(-8_193))
        #expect(MIDIPitchBend.isValid(-8_192))
        #expect(MIDIPitchBend.isValid(0))
        #expect(MIDIPitchBend.isValid(8_191))
        #expect(!MIDIPitchBend.isValid(8_192))
    }

    @Test
    func roundTrip() {
        let value = MIDIPitchBend(intValue: -1_234)

        #expect(value != nil)

        let bytes = value?.bytesValue

        #expect(bytes != nil)

        let roundTripped = bytes.flatMap { MIDIPitchBend(bytesValue: $0) }

        #expect(roundTripped?.intValue == -1_234)
    }
}
