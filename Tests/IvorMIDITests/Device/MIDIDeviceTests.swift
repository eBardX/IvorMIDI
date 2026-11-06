// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDIDeviceTests {
    private let identity = MIDIDeviceIdentity(manufacturer: .yamaha,
                                              family: 1,
                                              member: 2,
                                              softwareRevision: [0, 0, 0, 1])
}

// MARK: -

extension MIDIDeviceTests {
    @Test
    func init_model() {
        let model = MIDIDeviceModel(manufacturer: .yamaha,
                                    name: "Synth",
                                    tuningCodec: MIDIUniversalTuningCodec())
        let device = MIDIDevice(model: model,
                                address: .deviceID(5),
                                identity: identity)

        #expect(device.address == .deviceID(5))
        #expect(device.identity == identity)
        #expect(device.model?.name == "Synth")
        #expect(device.tuningCodec is MIDIUniversalTuningCodec)
    }

    @Test
    func init_model_defaultIdentity() {
        let device = MIDIDevice(model: MIDIDeviceModel(manufacturer: .yamaha, name: "Synth"),
                                address: .channel(1))

        #expect(device.identity == nil)
    }

    @Test
    func init_model_noCodec() {
        let device = MIDIDevice(model: MIDIDeviceModel(manufacturer: .yamaha, name: "Synth"),
                                address: .channel(1))

        #expect(device.tuningCodec == nil)
    }

    @Test
    func init_tuningCodec() {
        let device = MIDIDevice(tuningCodec: MIDIUniversalTuningCodec(),
                                address: .channel(5),
                                identity: identity)

        #expect(device.address == .channel(5))
        #expect(device.identity == identity)
        #expect(device.model == nil)
        #expect(device.tuningCodec is MIDIUniversalTuningCodec)
    }

    @Test
    func init_tuningCodec_unknownDevice() {
        let device = MIDIDevice(tuningCodec: nil,
                                address: .deviceID(5))

        #expect(device.identity == nil)
        #expect(device.model == nil)
        #expect(device.tuningCodec == nil)
    }
}
