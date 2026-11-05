// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorMIDI
import Testing
import XestiTools

struct MIDITuningChangeTests {
}

// MARK: -

extension MIDITuningChangeTests {
    @Test
    func codable() throws {
        let original = MIDITuningChange(key: 69,
                                        frequency: MIDITuningFrequency(semitone: 69, fraction: 300))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDITuningChange.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func equality() {
        let change = MIDITuningChange(key: 69, frequency: .noChange)
        let same = MIDITuningChange(key: 69, frequency: .noChange)

        #expect(change == same)
    }

    @Test
    func hashable() {
        let change = MIDITuningChange(key: 69, frequency: .noChange)
        let other = MIDITuningChange(key: 70, frequency: .noChange)

        #expect(Set([change, change, other]).count == 2)
    }

    @Test
    func inequality() {
        let change = MIDITuningChange(key: 69, frequency: .noChange)

        #expect(change != MIDITuningChange(key: 70, frequency: .noChange))
        #expect(change != MIDITuningChange(key: 69, frequency: MIDITuningFrequency(semitone: 69)))
    }

    @Test
    func init_keyFrequency() {
        let frequency = MIDITuningFrequency(semitone: 69, fraction: 300)
        let change = MIDITuningChange(key: 70, frequency: frequency)

        #expect(change.key == 70)
        #expect(change.frequency == frequency)
    }
}
