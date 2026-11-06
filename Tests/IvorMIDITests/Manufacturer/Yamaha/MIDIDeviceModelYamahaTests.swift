// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIDeviceModelYamahaTests {
}

// MARK: -

extension MIDIDeviceModelYamahaTests {
    @Test
    func catalog() {
        #expect(MIDIDeviceModel.catalog.map(\.name) == ["DX11", "TX81Z"])
    }

    @Test(arguments: [MIDIDeviceModel.yamahaDX11, .yamahaTX81Z])
    func models(model: MIDIDeviceModel) {
        #expect(model.family == nil)
        #expect(model.manufacturer == .yamaha)
        #expect(model.member == nil)
        #expect(model.tuningCodec is TX81ZTuningCodec)
    }

    @Test
    func names() {
        #expect(MIDIDeviceModel.yamahaDX11.name == "DX11")
        #expect(MIDIDeviceModel.yamahaTX81Z.name == "TX81Z")
    }

    @Test
    func neverMatchIdentity() {
        let identity = MIDIDeviceIdentity(manufacturer: .yamaha, family: 0, member: 0, softwareRevision: [0, 0, 0, 0])

        #expect(MIDIDeviceModel(matching: identity) == nil)
    }
}
