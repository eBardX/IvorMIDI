// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIDeviceModelTests {
    private let catalog = [MIDIDeviceModel(manufacturer: .yamaha,
                                           name: "No identity"),
                           MIDIDeviceModel(manufacturer: .yamaha,
                                           name: "First",
                                           family: 1,
                                           member: 2),
                           MIDIDeviceModel(manufacturer: .yamaha,
                                           name: "Family only",
                                           family: 3),
                           MIDIDeviceModel(manufacturer: .korg,
                                           name: "Second",
                                           family: 1,
                                           member: 2)]
}

// MARK: -

extension MIDIDeviceModelTests {
    @Test
    func init_defaults() {
        let model = MIDIDeviceModel(manufacturer: .yamaha,
                                    name: "TX81Z")

        #expect(model.family == nil)
        #expect(model.manufacturer == .yamaha)
        #expect(model.member == nil)
        #expect(model.name == "TX81Z")
        #expect(model.tuningCodec == nil)
    }

    @Test
    func init_storesValues() {
        let model = MIDIDeviceModel(manufacturer: .korg,
                                    name: "M1",
                                    family: 1,
                                    member: 2,
                                    tuningCodec: MIDIUniversalTuningCodec())

        #expect(model.family == 1)
        #expect(model.member == 2)
        #expect(model.tuningCodec is MIDIUniversalTuningCodec)
    }

    @Test
    func matching_catalog() {
        let identity = MIDIDeviceIdentity(manufacturer: .kawai,
                                          family: 0,
                                          member: 0,
                                          softwareRevision: [0, 0, 0, 0])

        #expect(MIDIDeviceModel(matching: identity) == nil)
    }

    @Test
    func matching_entry() {
        let first = MIDIDeviceIdentity(manufacturer: .yamaha, family: 1, member: 2, softwareRevision: [0, 0, 0, 0])
        let second = MIDIDeviceIdentity(manufacturer: .korg, family: 1, member: 2, softwareRevision: [0, 0, 0, 0])

        #expect(MIDIDeviceModel(matching: first, in: catalog)?.name == "First")
        #expect(MIDIDeviceModel(matching: second, in: catalog)?.name == "Second")
    }

    @Test
    func matching_entryWithoutMember() {
        let identity = MIDIDeviceIdentity(manufacturer: .yamaha, family: 3, member: 0, softwareRevision: [0, 0, 0, 0])

        #expect(MIDIDeviceModel(matching: identity, in: catalog) == nil)
    }

    @Test
    func matching_ignoresSoftwareRevision() {
        let identity = MIDIDeviceIdentity(manufacturer: .yamaha, family: 1, member: 2, softwareRevision: [9, 9, 9, 9])

        #expect(MIDIDeviceModel(matching: identity, in: catalog)?.name == "First")
    }

    @Test
    func matching_noMatch() {
        let family = MIDIDeviceIdentity(manufacturer: .yamaha, family: 9, member: 2, softwareRevision: [0, 0, 0, 0])
        let manufacturer = MIDIDeviceIdentity(manufacturer: .roland, family: 1, member: 2, softwareRevision: [0, 0, 0, 0])
        let member = MIDIDeviceIdentity(manufacturer: .yamaha, family: 1, member: 9, softwareRevision: [0, 0, 0, 0])

        #expect(MIDIDeviceModel(matching: family, in: catalog) == nil)
        #expect(MIDIDeviceModel(matching: manufacturer, in: catalog) == nil)
        #expect(MIDIDeviceModel(matching: member, in: catalog) == nil)
    }
}
