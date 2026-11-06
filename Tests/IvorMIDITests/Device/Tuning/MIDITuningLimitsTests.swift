// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing

struct MIDITuningLimitsTests {
    private let limits = MIDITuningLimits(maximumNameLength: 0,
                                          resolutionInCents: 1.5,
                                          soundingKeys: 13...108,
                                          supportsNoChange: false)
}

// MARK: -

extension MIDITuningLimitsTests {
    @Test
    func hashable() {
        let other = MIDITuningLimits(maximumNameLength: 16,
                                     resolutionInCents: 1.5,
                                     soundingKeys: 13...108,
                                     supportsNoChange: false)

        #expect(Set([limits, limits, other]).count == 2)
    }

    @Test
    func init_storesValues() {
        #expect(limits.maximumNameLength == 0)
        #expect(limits.resolutionInCents == 1.5)
        #expect(limits.soundingKeys == 13...108)
        #expect(!limits.supportsNoChange)
    }
}
