// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIRegisteredParameterTests {
}

// MARK: -

extension MIDIRegisteredParameterTests {
    @Test
    func codable() throws {
        let original: MIDIRegisteredParameter = 1
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIRegisteredParameter.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("16384".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDIRegisteredParameter.self,
                                     from: data)
        }
    }

    @Test
    func comparable() {
        let low: MIDIRegisteredParameter = 1
        let high: MIDIRegisteredParameter = 16_383

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func description() {
        let value: MIDIRegisteredParameter = 5

        #expect(value.description == "5")
    }

    @Test
    func equality() {
        let value1: MIDIRegisteredParameter = 1
        let value2: MIDIRegisteredParameter = 1
        let value3: MIDIRegisteredParameter = 2

        #expect(value1 == value2)
        #expect(value1 != value3)
    }

    @Test
    func hashable() {
        let set: Set<MIDIRegisteredParameter> = [1, 1, 2]

        #expect(set.count == 2)
    }

    @Test
    func init_integerLiteral() {
        let value: MIDIRegisteredParameter = 2

        #expect(value.uintValue == 2)
    }

    @Test
    func init_uintValue() {
        #expect(MIDIRegisteredParameter(uintValue: 0) != nil)
        #expect(MIDIRegisteredParameter(uintValue: 5) != nil)
        #expect(MIDIRegisteredParameter(uintValue: 16_383) != nil)
    }

    @Test
    func init_uintValue_invalid() {
        #expect(MIDIRegisteredParameter(uintValue: 16_384) == nil)
    }

    @Test
    func isValid() {
        #expect(MIDIRegisteredParameter.isValid(0))
        #expect(MIDIRegisteredParameter.isValid(16_383))
        #expect(!MIDIRegisteredParameter.isValid(16_384))
    }

    @Test
    func lsb() {
        #expect(MIDIRegisteredParameter.fineTuning.lsb == 1)
        #expect(MIDIRegisteredParameter.null.lsb == 127)
        #expect((130 as MIDIRegisteredParameter).lsb == 2)
    }

    @Test
    func msb() {
        #expect(MIDIRegisteredParameter.fineTuning.msb == 0)
        #expect(MIDIRegisteredParameter.null.msb == 127)
        #expect((130 as MIDIRegisteredParameter).msb == 1)
    }

    @Test
    func staticConstants() {
        #expect(MIDIRegisteredParameter.coarseTuning.uintValue == 2)
        #expect(MIDIRegisteredParameter.fineTuning.uintValue == 1)
        #expect(MIDIRegisteredParameter.modulationDepthRange.uintValue == 5)
        #expect(MIDIRegisteredParameter.null.uintValue == 16_383)
        #expect(MIDIRegisteredParameter.pitchBendSensitivity.uintValue == 0)
        #expect(MIDIRegisteredParameter.tuningBankSelect.uintValue == 4)
        #expect(MIDIRegisteredParameter.tuningProgramChange.uintValue == 3)
    }
}
