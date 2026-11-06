// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDIDeviceControlMessageContentTests {
}

// MARK: -

extension MIDIDeviceControlMessageContentTests {
    @Test
    func equality() {
        #expect(MIDIDeviceControlMessage.Content.masterVolume(5) == .masterVolume(5))
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        let contents: [MIDIDeviceControlMessage.Content] = [.masterCoarseTuning(5),
                                                            .masterFineTuning(5),
                                                            .masterVolume(5)]

        #expect(Set(contents).count == contents.count)
    }

    @Test
    func inequality() {
        #expect(MIDIDeviceControlMessage.Content.masterVolume(5) != .masterVolume(6))
    }
}
