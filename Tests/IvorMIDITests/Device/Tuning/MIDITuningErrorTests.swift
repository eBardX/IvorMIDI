// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDITuningErrorTests {
}

// MARK: -

extension MIDITuningErrorTests {
    @Test
    func equality() {
        #expect(MIDITuningError.unsupportedSlot(.table(1)) == .unsupportedSlot(.table(1)))
    }

    @Test
    func error_isThrowable() {
        #expect(throws: MIDITuningError.nonRepeatingTuning) {
            throw MIDITuningError.nonRepeatingTuning
        }
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        let errors: [MIDITuningError] = [.nonRepeatingTuning,
                                         .unsupportedAddress(.channel(1)),
                                         .unsupportedSlot(.table(1))]

        #expect(Set(errors).count == errors.count)
    }

    @Test
    func inequality() {
        #expect(MIDITuningError.unsupportedAddress(.channel(1)) != .unsupportedAddress(.channel(2)))
        #expect(MIDITuningError.unsupportedSlot(.table(0)) != .unsupportedSlot(.table(1)))
    }
}
