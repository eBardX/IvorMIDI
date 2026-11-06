// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDIDeviceIdentityTests {
}

// MARK: -

extension MIDIDeviceIdentityTests {
    @Test
    func hashable() {
        let identity = MIDIDeviceIdentity(manufacturer: .yamaha,
                                          family: 1,
                                          member: 2,
                                          softwareRevision: [0, 0, 0, 1])
        let other = MIDIDeviceIdentity(manufacturer: .yamaha,
                                       family: 1,
                                       member: 2,
                                       softwareRevision: [0, 0, 0, 2])

        #expect(Set([identity, identity, other]).count == 2)
    }

    @Test
    func init_storesValues() {
        let identity = MIDIDeviceIdentity(manufacturer: .korg,
                                          family: 1,
                                          member: 2,
                                          softwareRevision: [1, 2, 3, 4])

        #expect(identity.family == 1)
        #expect(identity.manufacturer == .korg)
        #expect(identity.member == 2)
        #expect(identity.softwareRevision == [1, 2, 3, 4])
    }
}
