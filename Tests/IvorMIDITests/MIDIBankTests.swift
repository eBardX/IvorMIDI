// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIBankTests {
}

// MARK: -

extension MIDIBankTests {
    @Test
    func codable() throws {
        let original: MIDIBank = 15_489
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIBank.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("16384".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDIBank.self,
                                     from: data)
        }
    }

    @Test
    func init_msbLSB() {
        #expect(MIDIBank(msb: 121, lsb: 1).uintValue == 15_489)
        #expect(MIDIBank(msb: 0, lsb: 8).uintValue == 8)
        #expect(MIDIBank(msb: 127, lsb: 127).uintValue == 16_383)
    }

    @Test(arguments: [0, 8, 16_383] as [UInt])
    func init_uintValue_inRange(value: UInt) {
        #expect(MIDIBank(uintValue: value)?.uintValue == value)
    }

    @Test
    func init_uintValue_outOfRange() {
        #expect(MIDIBank(uintValue: 16_384) == nil)
    }

    @Test
    func isValid() {
        #expect(MIDIBank.isValid(0))
        #expect(MIDIBank.isValid(16_383))
        #expect(!MIDIBank.isValid(16_384))
    }

    @Test
    func msbAndLSB() {
        let bank: MIDIBank = 15_489

        #expect(bank.msb == 121)
        #expect(bank.lsb == 1)
    }
}
