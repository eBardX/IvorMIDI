// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing

struct MIDITuningPrerequisiteTests {
}

// MARK: -

extension MIDITuningPrerequisiteTests {
    @Test
    func hashable_everyCaseIsDistinct() {
        let prerequisites: [MIDITuningPrerequisite] = [.exclusiveEnabled,
                                                       .memoryProtectOff,
                                                       .microTuningEnabled,
                                                       .performanceMode]

        #expect(Set(prerequisites).count == prerequisites.count)
    }
}
