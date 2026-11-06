// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing

struct MIDIDeviceTuningTests {
    private let frequencies = [MIDITuningFrequency](repeating: .noChange, count: 128)
}

// MARK: -

extension MIDIDeviceTuningTests {
    @Test
    func hashable() throws {
        let tuning = try #require(MIDIDeviceTuning(frequencies: frequencies))
        let named = try #require(MIDIDeviceTuning(frequencies: frequencies, name: "Just"))

        #expect(Set([tuning, tuning, named]).count == 2)
    }

    @Test
    func init_128Frequencies() {
        let tuning = MIDIDeviceTuning(frequencies: frequencies, name: "Just")

        #expect(tuning?.frequencies == frequencies)
        #expect(tuning?.name == "Just")
    }

    @Test
    func init_defaultName() {
        #expect(MIDIDeviceTuning(frequencies: frequencies)?.name == nil)
    }

    @Test(arguments: [0, 127, 129])
    func init_wrongCount(count: Int) {
        let values = [MIDITuningFrequency](repeating: .noChange, count: count)

        #expect(MIDIDeviceTuning(frequencies: values) == nil)
    }
}
