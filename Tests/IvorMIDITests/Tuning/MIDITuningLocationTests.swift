// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorMIDI
import Testing
import XestiTools

struct MIDITuningLocationTests {
}

// MARK: -

extension MIDITuningLocationTests {
    @Test
    func codable_bank() throws {
        let original = MIDITuningLocation(program: 5, bank: 2)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDITuningLocation.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_noBank() throws {
        let original = MIDITuningLocation(program: 5)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDITuningLocation.self,
                                               from: data)

        #expect(decoded == original)
        #expect(decoded.bank == nil)
    }

    @Test
    func equality() {
        #expect(MIDITuningLocation(program: 5) == MIDITuningLocation(program: 5, bank: nil))

        let location = MIDITuningLocation(program: 5, bank: 2)
        let same = MIDITuningLocation(program: 5, bank: 2)

        #expect(location == same)
    }

    @Test
    func hashable() {
        let location = MIDITuningLocation(program: 5)
        let other = MIDITuningLocation(program: 5, bank: 0)

        #expect(Set([location, location, other]).count == 2)
    }

    @Test
    func inequality() {
        #expect(MIDITuningLocation(program: 5) != MIDITuningLocation(program: 6))
        #expect(MIDITuningLocation(program: 5, bank: 2) != MIDITuningLocation(program: 5, bank: 3))
    }

    @Test
    func inequality_noBankIsNotBankZero() {
        #expect(MIDITuningLocation(program: 5) != MIDITuningLocation(program: 5, bank: 0))
    }

    @Test
    func init_bank() {
        let location = MIDITuningLocation(program: 5, bank: 2)

        #expect(location.program == 5)
        #expect(location.bank == 2)
    }

    @Test
    func init_defaultsToNoBank() {
        #expect(MIDITuningLocation(program: 5).bank == nil)
    }
}
