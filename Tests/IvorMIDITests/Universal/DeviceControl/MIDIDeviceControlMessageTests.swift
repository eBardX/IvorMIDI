// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDIDeviceControlMessageTests {
}

// MARK: -

extension MIDIDeviceControlMessageTests {
    @Test
    func deviceID() {
        #expect(MIDIDeviceControlMessage(content: .masterVolume(0)).deviceID == 0x7f)
        #expect(MIDIDeviceControlMessage(content: .masterVolume(0), deviceID: 0x10).systemMessage?.dataBytes
                == [0x7f, 0x10, 0x04, 0x01, 0x00, 0x00, 0xf7])
    }

    @Test
    func envelope() {
        #expect(MIDIDeviceControlMessage(content: .masterVolume(128)).envelope
                == .universal(.deviceControl, deviceID: 127, payload: [0x01, 0x00, 0x01]))
    }

    @Test
    func hashable() {
        let message = MIDIDeviceControlMessage(content: .masterVolume(1))
        let other = MIDIDeviceControlMessage(content: .masterVolume(1), deviceID: 0x10)

        #expect(Set([message, message, other]).count == 2)
    }

    @Test
    func init_envelope_coarseTuningIgnoresPadding() {
        let message = MIDIDeviceControlMessage(MIDISysExEnvelope.universal(.deviceControl,
                                                                           deviceID: 127,
                                                                           payload: [0x04, 0x55, 0x4c]))

        #expect(message?.content == .masterCoarseTuning(0x4c))
    }

    @Test
    func init_envelope_dataByteAbove7F() {
        #expect(MIDIDeviceControlMessage(MIDISysExEnvelope.universal(.deviceControl,
                                                                     deviceID: 127,
                                                                     payload: [0x01, 0x80, 0x00])) == nil)
    }

    @Test
    func init_envelope_otherMessages() {
        #expect(MIDIDeviceControlMessage(MIDISysExEnvelope.nonCommercial(payload: [0x01, 0x00, 0x00])) == nil)
        #expect(MIDIDeviceControlMessage(MIDISysExEnvelope.universal(.generalInformation,
                                                                     deviceID: 127,
                                                                     payload: [0x01, 0x00, 0x00])) == nil)
        #expect(MIDIDeviceControlMessage(MIDISysExEnvelope.universal(MIDISysExUniversalID(realTime: false, subID: 0x04),
                                                                     deviceID: 127,
                                                                     payload: [0x01, 0x00, 0x00])) == nil)
    }

    @Test
    func init_envelope_unknownSubID() {
        #expect(MIDIDeviceControlMessage(MIDISysExEnvelope.universal(.deviceControl,
                                                                     deviceID: 127,
                                                                     payload: [0x02, 0x00, 0x00])) == nil)
    }

    @Test
    func init_envelope_wrongLength() {
        #expect(MIDIDeviceControlMessage(MIDISysExEnvelope.universal(.deviceControl,
                                                                     deviceID: 127,
                                                                     payload: [0x01, 0x00])) == nil)
        #expect(MIDIDeviceControlMessage(MIDISysExEnvelope.universal(.deviceControl,
                                                                     deviceID: 127,
                                                                     payload: [0x01, 0x00, 0x00, 0x00])) == nil)
    }

    @Test
    func masterCoarseTuning() {
        #expect(MIDIDeviceControlMessage(content: .masterCoarseTuning(0x40)).systemMessage?.dataBytes
                == [0x7f, 0x7f, 0x04, 0x04, 0x00, 0x40, 0xf7])
        #expect(MIDIDeviceControlMessage(content: .masterCoarseTuning(0x4c)).systemMessage?.dataBytes
                == [0x7f, 0x7f, 0x04, 0x04, 0x00, 0x4c, 0xf7])
    }

    @Test
    func masterCoarseTuning_parsesFromBytes() {
        let message = MIDIDeviceControlMessage(content: .masterCoarseTuning(0x4c)).systemMessage

        #expect(MIDISystemMessage(statusByte: 0xf0,
                                  dataBytes: message?.dataBytes ?? []) == message)
    }

    @Test
    func masterFineTuning() {
        // The default, A440, is LSB 00, MSB 40.
        #expect(MIDIDeviceControlMessage(content: .masterFineTuning(8_192)).systemMessage?.dataBytes
                == [0x7f, 0x7f, 0x04, 0x03, 0x00, 0x40, 0xf7])
        #expect(MIDIDeviceControlMessage(content: .masterFineTuning(16_383)).systemMessage?.dataBytes
                == [0x7f, 0x7f, 0x04, 0x03, 0x7f, 0x7f, 0xf7])
        #expect(MIDIDeviceControlMessage(content: .masterFineTuning(1)).systemMessage?.dataBytes
                == [0x7f, 0x7f, 0x04, 0x03, 0x01, 0x00, 0xf7])
    }

    @Test
    func masterFineTuning_parsesFromBytes() {
        let message = MIDIDeviceControlMessage(content: .masterFineTuning(12_345)).systemMessage

        #expect(MIDISystemMessage(statusByte: 0xf0,
                                  dataBytes: message?.dataBytes ?? []) == message)
    }

    @Test
    func masterVolume() {
        #expect(MIDIDeviceControlMessage(content: .masterVolume(16_383)).systemMessage?.dataBytes
                == [0x7f, 0x7f, 0x04, 0x01, 0x7f, 0x7f, 0xf7])
        #expect(MIDIDeviceControlMessage(content: .masterVolume(0)).systemMessage?.dataBytes
                == [0x7f, 0x7f, 0x04, 0x01, 0x00, 0x00, 0xf7])
        #expect(MIDIDeviceControlMessage(content: .masterVolume(128)).systemMessage?.dataBytes
                == [0x7f, 0x7f, 0x04, 0x01, 0x00, 0x01, 0xf7])
    }

    @Test
    func masterVolume_parsesFromBytes() {
        let message = MIDIDeviceControlMessage(content: .masterVolume(12_345)).systemMessage

        #expect(MIDISystemMessage(statusByte: 0xf0,
                                  dataBytes: message?.dataBytes ?? []) == message)
    }

    @Test(arguments: [.masterCoarseTuning(0),
                      .masterCoarseTuning(127),
                      .masterFineTuning(0),
                      .masterFineTuning(12_345),
                      .masterVolume(16_383)] as [MIDIDeviceControlMessage.Content])
    func roundTrip(content: MIDIDeviceControlMessage.Content) throws {
        let original = MIDIDeviceControlMessage(content: content, deviceID: 0x10)
        let message = try #require(original.systemMessage)

        #expect(MIDIDeviceControlMessage(message) == original)
    }
}
