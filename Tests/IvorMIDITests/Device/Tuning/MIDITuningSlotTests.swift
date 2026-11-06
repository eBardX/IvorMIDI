// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDITuningSlotTests {
}

// MARK: -

extension MIDITuningSlotTests {
    @Test
    func equality() {
        #expect(MIDITuningSlot.program(bank: 2, 5) == .program(bank: 2, 5))
        #expect(MIDITuningSlot.table(1) == .table(1))
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        let slots: [MIDITuningSlot] = [.program(bank: nil, 0),
                                       .table(0)]

        #expect(Set(slots).count == slots.count)
    }

    @Test
    func inequality() {
        #expect(MIDITuningSlot.program(bank: nil, 5) != .program(bank: 0, 5))
        #expect(MIDITuningSlot.table(0) != .table(1))
    }
}
