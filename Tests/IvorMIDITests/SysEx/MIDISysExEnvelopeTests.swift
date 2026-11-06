// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct MIDISysExEnvelopeTests {
}

// MARK: -

extension MIDISysExEnvelopeTests {
    @Test
    func hashable() {
        let set: Set<MIDISysExEnvelope> = [.nonCommercial(payload: [0x01]),
                                           .nonCommercial(payload: [0x01]),
                                           .nonCommercial(payload: [0x02])]

        #expect(set.count == 2)
    }

    @Test
    func hasValidPayload() {
        #expect(MIDISysExEnvelope.manufacturer(.yamaha, payload: [0x00, 0x7f]).hasValidPayload)
        #expect(MIDISysExEnvelope.nonCommercial(payload: []).hasValidPayload)
        #expect(MIDISysExEnvelope.universal(.tuning, deviceID: 127, payload: [0x7f]).hasValidPayload)
    }

    @Test
    func hasValidPayload_dataByteAbove7F() {
        #expect(!MIDISysExEnvelope.manufacturer(.yamaha, payload: [0x00, 0x80]).hasValidPayload)
        #expect(!MIDISysExEnvelope.nonCommercial(payload: [0xf7]).hasValidPayload)
        #expect(!MIDISysExEnvelope.universal(.tuning, deviceID: 127, payload: [0xff]).hasValidPayload)
    }

    @Test
    func init_dataByteAbove7F() {
        #expect(MIDISysExEnvelope(.systemExclusive([0x43, 0x80, 0xf7])) == nil)
        #expect(MIDISysExEnvelope(.systemExclusive([0x7e, 0x7f, 0x06, 0xff, 0xf7])) == nil)
        #expect(MIDISysExEnvelope(.systemExclusive([0x7d, 0xf7, 0x01, 0xf7])) == nil)
    }

    @Test
    func init_empty() {
        #expect(MIDISysExEnvelope(.systemExclusive([])) == nil)
        #expect(MIDISysExEnvelope(.systemExclusive([0xf7])) == nil)
    }

    @Test
    func init_emptyPayloads() {
        #expect(MIDISysExEnvelope(.systemExclusive([0x43, 0xf7])) == .manufacturer(.yamaha, payload: []))
        #expect(MIDISysExEnvelope(.systemExclusive([0x7d, 0xf7])) == .nonCommercial(payload: []))
        #expect(MIDISysExEnvelope(.systemExclusive([0x7e, 0x7f, 0x06, 0xf7])) == .universal(.generalInformation,
                                                                                            deviceID: 127,
                                                                                            payload: []))
    }

    @Test
    func init_malformedUniversal() {
        #expect(MIDISysExEnvelope(.systemExclusive([0x7e, 0x7f, 0xf7])) == nil)
        #expect(MIDISysExEnvelope(.systemExclusive([0x7f, 0xf7])) == nil)
    }

    @Test
    func init_noEOX() {
        #expect(MIDISysExEnvelope(.systemExclusive([0x43, 0x00])) == nil)
    }

    @Test(arguments: [.activeSensing,
                      .eox,
                      .songSelect(5),
                      .timingClock] as [MIDISystemMessage])
    func init_notSystemExclusive(message: MIDISystemMessage) {
        #expect(MIDISysExEnvelope(message) == nil)
    }

    @Test
    func init_oneByteZeroManufacturerID() {
        #expect(MIDISysExEnvelope(.systemExclusive([0x00, 0xf7])) == nil)
    }

    @Test
    func init_truncatedManufacturerID() {
        #expect(MIDISysExEnvelope(.systemExclusive([0x00, 0x21, 0xf7])) == nil)
    }

    @Test
    func mapping_identityRequest() {
        let bytes: [UInt8] = [0x7e, 0x7f, 0x06, 0x01, 0xf7]
        let envelope = MIDISysExEnvelope.universal(.generalInformation,
                                                   deviceID: 127,
                                                   payload: [0x01])

        #expect(MIDISysExEnvelope(.systemExclusive(bytes)) == envelope)
        #expect(envelope.systemMessage == .systemExclusive(bytes))
    }

    @Test
    func mapping_masterVolume() {
        let bytes: [UInt8] = [0x7f, 0x7f, 0x04, 0x01, 0x12, 0x34, 0xf7]
        let envelope = MIDISysExEnvelope.universal(.deviceControl,
                                                   deviceID: 127,
                                                   payload: [0x01, 0x12, 0x34])

        #expect(MIDISysExEnvelope(.systemExclusive(bytes)) == envelope)
        #expect(envelope.systemMessage == .systemExclusive(bytes))
    }

    @Test
    func mapping_nonCommercial() {
        let bytes: [UInt8] = [0x7d, 0x01, 0x02, 0xf7]
        let envelope = MIDISysExEnvelope.nonCommercial(payload: [0x01, 0x02])

        #expect(MIDISysExEnvelope(.systemExclusive(bytes)) == envelope)
        #expect(envelope.systemMessage == .systemExclusive(bytes))
    }

    @Test
    func mapping_sampleDumpHeader() {
        let bytes: [UInt8] = [0x7e, 0x05, 0x01, 0x10, 0x20, 0x30, 0xf7]
        let envelope = MIDISysExEnvelope.universal(MIDISysExUniversalID(realTime: false,
                                                                        subID: 0x01),
                                                   deviceID: 5,
                                                   payload: [0x10, 0x20, 0x30])

        #expect(MIDISysExEnvelope(.systemExclusive(bytes)) == envelope)
        #expect(envelope.systemMessage == .systemExclusive(bytes))
    }

    @Test
    func mapping_threeByteManufacturer() throws {
        let bytes: [UInt8] = [0x00, 0x21, 0x09, 0x55, 0xf7]
        let id = try #require(MIDIManufacturerID(bytes: [0x00, 0x21, 0x09]))
        let envelope = MIDISysExEnvelope.manufacturer(id,
                                                      payload: [0x55])

        #expect(MIDISysExEnvelope(.systemExclusive(bytes)) == envelope)
        #expect(envelope.systemMessage == .systemExclusive(bytes))
    }

    @Test
    func mapping_tx81zFullKeyboardDump() {
        let bytes: [UInt8] = [0x43, 0x03, 0x7e, 0x02, 0x0a, 0x4c, 0x4d, 0x20, 0x55, 0xf7]
        let envelope = MIDISysExEnvelope.manufacturer(.yamaha,
                                                      payload: [0x03, 0x7e, 0x02, 0x0a, 0x4c, 0x4d, 0x20, 0x55])

        #expect(MIDISysExEnvelope(.systemExclusive(bytes)) == envelope)
        #expect(envelope.systemMessage == .systemExclusive(bytes))
    }

    @Test
    func patternMatching_manufacturerConstant() {
        var matched = false

        if case .manufacturer(.yamaha, _) = MIDISysExEnvelope.manufacturer(.yamaha, payload: []) {
            matched = true
        }

        #expect(matched)
    }

    @Test(arguments: [(.systemExclusive([0x7e, 0x7f, 0xf7]), "malformed"),
                      (.systemExclusive([0x43, 0x01, 0xf7]), "yamaha 1"),
                      (.systemExclusive([0x42, 0xf7]), "manufacturer [66]"),
                      (.systemExclusive([0x7d, 0xf7]), "non-commercial"),
                      (.systemExclusive([0x7e, 0x7f, 0x06, 0x01, 0xf7]), "general information"),
                      (.systemExclusive([0x7f, 0x7f, 0x08, 0x02, 0xf7]), "tuning"),
                      (.systemExclusive([0x7e, 0x05, 0x01, 0xf7]), "universal 1, device 5")] as [(MIDISystemMessage, String)])
    func patternMatching_optionalEnvelope(message: MIDISystemMessage,
                                          expected: String) {
        let label = switch MIDISysExEnvelope(message) {
        case .none:
            "malformed"

        case let .manufacturer(.yamaha, payload):
            "yamaha \(payload.count)"

        case let .manufacturer(id, _):
            "manufacturer \(id.bytes)"

        case .nonCommercial:
            "non-commercial"

        case .universal(.generalInformation, _, _):
            "general information"

        case .universal(.realTimeTuning, _, _),
             .universal(.tuning, _, _):
            "tuning"

        case let .universal(id, deviceID, _):
            "universal \(id.subID.uintValue), device \(deviceID.uintValue)"
        }

        #expect(label == expected)
    }

    @Test
    func patternMatching_universalConstant() {
        var matched = false

        if case .universal(.tuning, _, _) = MIDISysExEnvelope.universal(.tuning, deviceID: 0, payload: []) {
            matched = true
        }

        #expect(matched)
    }

    @Test
    func patternMatching_universalConstant_differentHeader() {
        var matched = false

        if case .universal(.tuning, _, _) = MIDISysExEnvelope.universal(.realTimeTuning, deviceID: 0, payload: []) {
            matched = true
        }

        #expect(!matched)
    }

    @Test
    func systemMessage_dataByteAbove7F() {
        #expect(MIDISysExEnvelope.manufacturer(.yamaha, payload: [0x00, 0x80]).systemMessage == nil)
        #expect(MIDISysExEnvelope.nonCommercial(payload: [0xf7]).systemMessage == nil)
        #expect(MIDISysExEnvelope.universal(.tuning, deviceID: 127, payload: [0xff]).systemMessage == nil)
    }
}
