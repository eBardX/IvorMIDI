// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDINonRegisteredParameterTests {
}

// MARK: -

extension MIDINonRegisteredParameterTests {
    @Test
    func codable() throws {
        let original: MIDINonRegisteredParameter = 1
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDINonRegisteredParameter.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("16384".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDINonRegisteredParameter.self,
                                     from: data)
        }
    }

    @Test
    func comparable() {
        let low: MIDINonRegisteredParameter = 1
        let high: MIDINonRegisteredParameter = 16_383

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func description() {
        let value: MIDINonRegisteredParameter = 5

        #expect(value.description == "5")
    }

    @Test
    func equality() {
        let value1: MIDINonRegisteredParameter = 1
        let value2: MIDINonRegisteredParameter = 1
        let value3: MIDINonRegisteredParameter = 2

        #expect(value1 == value2)
        #expect(value1 != value3)
    }

    @Test
    func hashable() {
        let set: Set<MIDINonRegisteredParameter> = [1, 1, 2]

        #expect(set.count == 2)
    }

    @Test
    func init_integerLiteral() {
        let value: MIDINonRegisteredParameter = 2

        #expect(value.uintValue == 2)
    }

    @Test
    func init_uintValue() {
        #expect(MIDINonRegisteredParameter(uintValue: 0) != nil)
        #expect(MIDINonRegisteredParameter(uintValue: 5) != nil)
        #expect(MIDINonRegisteredParameter(uintValue: 16_383) != nil)
    }

    @Test
    func init_uintValue_invalid() {
        #expect(MIDINonRegisteredParameter(uintValue: 16_384) == nil)
    }

    @Test
    func isValid() {
        #expect(MIDINonRegisteredParameter.isValid(0))
        #expect(MIDINonRegisteredParameter.isValid(16_383))
        #expect(!MIDINonRegisteredParameter.isValid(16_384))
    }

    @Test
    func lsb() {
        #expect((0 as MIDINonRegisteredParameter).lsb == 0)
        #expect((130 as MIDINonRegisteredParameter).lsb == 2)
        #expect((16_383 as MIDINonRegisteredParameter).lsb == 127)
    }

    @Test
    func msb() {
        #expect((0 as MIDINonRegisteredParameter).msb == 0)
        #expect((130 as MIDINonRegisteredParameter).msb == 1)
        #expect((16_383 as MIDINonRegisteredParameter).msb == 127)
    }
}
