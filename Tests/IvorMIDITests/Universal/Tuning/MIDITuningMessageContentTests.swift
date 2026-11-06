// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDITuningMessageContentTests {
    private let change = MIDITuningChange(key: 69, frequency: .noChange)
    private let frequencies = [MIDITuningFrequency](repeating: .noChange, count: 128)
    private let location = MIDITuningLocation(program: 5)
    private let offsets = MIDITuningOffsets.coarse([MIDIData1Value](repeating: 0x40, count: 12))
}

// MARK: -

extension MIDITuningMessageContentTests {
    @Test
    func equality() {
        #expect(MIDITuningMessage.Content.singleNoteChange(location, changes: [change], realTime: true)
                == .singleNoteChange(location, changes: [change], realTime: true))
    }

    @Test
    func hashable() {
        let content = MIDITuningMessage.Content.dumpRequest(location)

        #expect(Set([content, content]).count == 1)
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        let contents: [MIDITuningMessage.Content] = [.dumpRequest(location),
                                                     .keyBasedDump(location, name: "", frequencies: frequencies),
                                                     .scaleOctaveDump(bank: 0, program: 5, name: "", offsets: offsets),
                                                     .scaleOctaveTuning(channels: [1], offsets: offsets, realTime: false),
                                                     .singleNoteChange(location, changes: [change], realTime: false)]

        #expect(Set(contents).count == contents.count)
    }

    @Test
    func inequality_dumpRequest() {
        #expect(MIDITuningMessage.Content.dumpRequest(location)
                != .dumpRequest(MIDITuningLocation(program: 5, bank: 0)))
    }

    @Test
    func inequality_keyBasedDump() {
        let content = MIDITuningMessage.Content.keyBasedDump(location, name: "a", frequencies: frequencies)

        #expect(content != .keyBasedDump(location, name: "b", frequencies: frequencies))
        #expect(content != .keyBasedDump(location, name: "a", frequencies: []))
    }

    @Test
    func inequality_realTime() {
        #expect(MIDITuningMessage.Content.scaleOctaveTuning(channels: [1], offsets: offsets, realTime: false)
                != .scaleOctaveTuning(channels: [1], offsets: offsets, realTime: true))
        #expect(MIDITuningMessage.Content.singleNoteChange(location, changes: [change], realTime: false)
                != .singleNoteChange(location, changes: [change], realTime: true))
    }

    @Test
    func inequality_scaleOctaveDump() {
        #expect(MIDITuningMessage.Content.scaleOctaveDump(bank: 0, program: 5, name: "", offsets: offsets)
                != .scaleOctaveDump(bank: 1, program: 5, name: "", offsets: offsets))
    }
}
