// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct TX81ZTuningMessageContentTests {
}

// MARK: -

extension TX81ZTuningMessageContentTests {
    @Test
    func equality() {
        #expect(TX81ZTuningMessage.Content.microTuneKey(5) == .microTuneKey(5))
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        let contents: [TX81ZTuningMessage.Content] = [.dump(.octave, pitches: []),
                                                      .dumpRequest(.octave),
                                                      .microTuneEnable(instrument: 1, isEnabled: true),
                                                      .microTuneKey(1),
                                                      .microTuneTable(.table(.octave))]

        #expect(Set(contents).count == contents.count)
    }

    @Test
    func inequality() {
        #expect(TX81ZTuningMessage.Content.dumpRequest(.octave) != .dumpRequest(.fullKeyboard))
        #expect(TX81ZTuningMessage.Content.microTuneEnable(instrument: 1, isEnabled: true)
                != .microTuneEnable(instrument: 1, isEnabled: false))
    }
}
