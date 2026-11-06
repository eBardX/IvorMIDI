// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing

struct MIDITuningSlotTX81ZTests {
}

// MARK: -

extension MIDITuningSlotTX81ZTests {
    @Test
    func constants() {
        #expect(MIDITuningSlot.tx81zFullKeyboard == .table(1))
        #expect(MIDITuningSlot.tx81zOctave == .table(0))
    }
}
