// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDIDeviceAddressTests {
}

// MARK: -

extension MIDIDeviceAddressTests {
    @Test
    func equality() {
        #expect(MIDIDeviceAddress.channel(5) == .channel(5))
        #expect(MIDIDeviceAddress.deviceID(5) == .deviceID(5))
    }

    @Test
    func hashable_everyCaseIsDistinct() {
        let addresses: [MIDIDeviceAddress] = [.channel(5),
                                              .deviceID(5)]

        #expect(Set(addresses).count == addresses.count)
    }

    @Test
    func inequality() {
        #expect(MIDIDeviceAddress.channel(5) != .channel(6))
        #expect(MIDIDeviceAddress.deviceID(5) != .deviceID(6))
    }
}
