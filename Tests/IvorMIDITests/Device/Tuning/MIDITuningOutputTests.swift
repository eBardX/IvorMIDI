// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing

struct MIDITuningOutputTests {
}

// MARK: -

extension MIDITuningOutputTests {
    @Test
    func init_defaults() {
        let output = MIDITuningOutput(messages: [.start])

        #expect(output.messages == [.start])
        #expect(output.adjustments.isEmpty)
        #expect(output.prerequisites.isEmpty)
    }

    @Test
    func init_storesValues() {
        let output = MIDITuningOutput(messages: [.start, .stop],
                                      adjustments: [.droppedName],
                                      prerequisites: [.exclusiveEnabled])

        #expect(output.messages == [.start, .stop])
        #expect(output.adjustments == [.droppedName])
        #expect(output.prerequisites == [.exclusiveEnabled])
    }
}
