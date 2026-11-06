// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDIIdentityMessageContentTests {
    private let identity = MIDIDeviceIdentity(manufacturer: .yamaha,
                                              family: 1,
                                              member: 2,
                                              softwareRevision: [0, 0, 0, 1])
}

// MARK: -

extension MIDIIdentityMessageContentTests {
    @Test
    func equality() {
        #expect(MIDIIdentityMessage.Content.reply(identity) == .reply(identity))
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        let contents: [MIDIIdentityMessage.Content] = [.reply(identity),
                                                       .request]

        #expect(Set(contents).count == contents.count)
    }
}
