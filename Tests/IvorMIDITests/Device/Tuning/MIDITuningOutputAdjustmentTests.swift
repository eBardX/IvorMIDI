// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing

struct MIDITuningOutputAdjustmentTests {
}

// MARK: -

extension MIDITuningOutputAdjustmentTests {
    @Test
    func equality() {
        #expect(MIDITuningOutput.Adjustment.clamped(keys: [1, 2]) == .clamped(keys: [1, 2]))
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        let adjustments: [MIDITuningOutput.Adjustment] = [.clamped(keys: [1]),
                                                          .droppedName,
                                                          .replacedNoChange(keys: [1]),
                                                          .rounded(maximumCents: 0.75)]

        #expect(Set(adjustments).count == adjustments.count)
    }

    @Test
    func inequality() {
        #expect(MIDITuningOutput.Adjustment.rounded(maximumCents: 0.5) != .rounded(maximumCents: 0.75))
        #expect(MIDITuningOutput.Adjustment.clamped(keys: [1]) != .replacedNoChange(keys: [1]))
    }
}
