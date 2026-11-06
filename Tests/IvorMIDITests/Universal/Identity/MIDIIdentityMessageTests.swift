// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDIIdentityMessageTests {
    private let identity = MIDIDeviceIdentity(manufacturer: .yamaha,
                                              family: 0x1a12,
                                              member: 0x2b56,
                                              softwareRevision: [0x01, 0x02, 0x03, 0x04])
}

// MARK: -

extension MIDIIdentityMessageTests {
    @Test
    func envelope_reply() {
        let message = MIDIIdentityMessage(content: .reply(identity), deviceID: 0x10)

        #expect(message.envelope == .universal(.generalInformation,
                                               deviceID: 0x10,
                                               payload: [0x02, 0x43, 0x12, 0x34, 0x56, 0x56, 0x01, 0x02, 0x03, 0x04]))
    }

    @Test
    func envelope_request() {
        #expect(MIDIIdentityMessage(content: .request).envelope == .universal(.generalInformation,
                                                                              deviceID: 127,
                                                                              payload: [0x01]))
    }

    @Test(arguments: [[], [0x01, 0x02, 0x03], [0x01, 0x02, 0x03, 0x04, 0x05], [0x01, 0x02, 0x03, 0x80]] as [[UInt8]])
    func envelope_softwareRevisionNotEncodable(revision: [UInt8]) {
        let identity = MIDIDeviceIdentity(manufacturer: .yamaha,
                                          family: 0,
                                          member: 0,
                                          softwareRevision: revision)

        #expect(MIDIIdentityMessage(content: .reply(identity)).envelope == nil)
    }

    @Test
    func hashable() {
        let message = MIDIIdentityMessage(content: .request)
        let other = MIDIIdentityMessage(content: .request, deviceID: 0x10)

        #expect(Set([message, message, other]).count == 2)
    }

    @Test
    func init_content() {
        #expect(MIDIIdentityMessage(content: .request).content == .request)
        #expect(MIDIIdentityMessage(content: .request).deviceID == 0x7f)
        #expect(MIDIIdentityMessage(content: .request, deviceID: 0x10).deviceID == 0x10)
    }

    @Test
    func init_envelope_dataByteAbove7F() {
        #expect(MIDIIdentityMessage(MIDISysExEnvelope.universal(.generalInformation,
                                                                deviceID: 127,
                                                                payload: [0x02, 0x43, 0x12, 0x34, 0x56, 0x56, 0x01, 0x02, 0x03, 0x80])) == nil)
    }

    @Test
    func init_message_reply_invalidManufacturerID() {
        for byte: UInt8 in [0x7d, 0x7e, 0x7f] {
            #expect(MIDIIdentityMessage(.systemExclusive([0x7e, 0x10, 0x06, 0x02, byte]
                                                         + [0x12, 0x34, 0x56, 0x56, 0x01, 0x02, 0x03, 0x04, 0xf7])) == nil)
        }
    }

    @Test
    func init_message_reply_oneByteManufacturerID() {
        let message = MIDIIdentityMessage(.systemExclusive([0x7e,
                                                            0x10,
                                                            0x06,
                                                            0x02,
                                                            0x43,
                                                            0x12,
                                                            0x34,
                                                            0x56,
                                                            0x56,
                                                            0x01,
                                                            0x02,
                                                            0x03,
                                                            0x04,
                                                            0xf7]))

        #expect(message?.deviceID == 0x10)
        #expect(message?.content == .reply(identity))
    }

    @Test
    func init_message_reply_threeByteManufacturerID() throws {
        let manufacturer = try #require(MIDIManufacturerID(bytes: [0x00, 0x21, 0x09]))
        let message = MIDIIdentityMessage(.systemExclusive([0x7e, 0x10, 0x06, 0x02, 0x00, 0x21, 0x09]
                                                           + [0x12, 0x34, 0x56, 0x56, 0x01, 0x02, 0x03, 0x04, 0xf7]))

        #expect(message?.content == .reply(MIDIDeviceIdentity(manufacturer: manufacturer,
                                                              family: 0x1a12,
                                                              member: 0x2b56,
                                                              softwareRevision: [0x01, 0x02, 0x03, 0x04])))
    }

    @Test
    func init_message_reply_wrongLength() {
        let header: [UInt8] = [0x7e, 0x10, 0x06, 0x02]
        let codes: [UInt8] = [0x12, 0x34, 0x56, 0x56]

        // 1-byte ID.
        #expect(MIDIIdentityMessage(.systemExclusive(header + [0x43] + codes + [0x01, 0x02, 0x03, 0xf7])) == nil)
        #expect(MIDIIdentityMessage(.systemExclusive(header + [0x43] + codes + [0x01, 0x02, 0x03, 0x04, 0x05, 0xf7])) == nil)

        // 3-byte ID whose length would suit a 1-byte ID.
        #expect(MIDIIdentityMessage(.systemExclusive(header + [0x00] + codes + [0x01, 0x02, 0x03, 0x04, 0xf7])) == nil)

        // No manufacturer ID.
        #expect(MIDIIdentityMessage(.systemExclusive(header + [0xf7])) == nil)
    }

    @Test
    func init_message_request() {
        let message = MIDIIdentityMessage(.systemExclusive([0x7e, 0x7f, 0x06, 0x01, 0xf7]))

        #expect(message?.deviceID == 0x7f)
        #expect(message?.content == .request)
    }

    @Test
    func init_message_request_extraBytes() {
        #expect(MIDIIdentityMessage(.systemExclusive([0x7e, 0x7f, 0x06, 0x01, 0x00, 0xf7])) == nil)
    }

    @Test
    func init_message_wrongOwner() {
        #expect(MIDIIdentityMessage(.systemExclusive([0x7f, 0x7f, 0x06, 0x01, 0xf7])) == nil)   // Real-time header
        #expect(MIDIIdentityMessage(.systemExclusive([0x7e, 0x7f, 0x07, 0x01, 0xf7])) == nil)   // Other sub-ID#1
        #expect(MIDIIdentityMessage(.systemExclusive([0x43, 0x7f, 0x06, 0x01, 0xf7])) == nil)   // Manufacturer
    }

    @Test
    func init_message_wrongSubID() {
        #expect(MIDIIdentityMessage(.systemExclusive([0x7e, 0x7f, 0x06, 0xf7])) == nil)
        #expect(MIDIIdentityMessage(.systemExclusive([0x7e, 0x7f, 0x06, 0x03, 0xf7])) == nil)
    }

    @Test
    func roundTrip() throws {
        for content: MIDIIdentityMessage.Content in [.request, .reply(identity)] {
            let original = MIDIIdentityMessage(content: content, deviceID: 0x10)
            let message = try #require(original.systemMessage)

            #expect(MIDIIdentityMessage(message) == original)
        }
    }

    @Test
    func systemMessage_request() {
        #expect(MIDIIdentityMessage(content: .request).systemMessage == .systemExclusive([0x7e, 0x7f, 0x06, 0x01, 0xf7]))
    }
}
