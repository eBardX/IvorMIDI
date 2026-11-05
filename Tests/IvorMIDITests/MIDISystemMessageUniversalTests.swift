// © 2026 John Gary Pusey (see LICENSE.md)

import IvorMIDI
import Testing
import XestiTools

struct MIDISystemMessageUniversalTests {
}

// MARK: -

extension MIDISystemMessageUniversalTests {
    @Test
    func masterCoarseTuning() {
        #expect(MIDISystemMessage.masterCoarseTuning(0x40).dataBytes == [0x7f, 0x7f, 0x04, 0x04, 0x00, 0x40, 0xf7])
        #expect(MIDISystemMessage.masterCoarseTuning(0x4c).dataBytes == [0x7f, 0x7f, 0x04, 0x04, 0x00, 0x4c, 0xf7])
    }

    @Test
    func masterCoarseTuning_parsesFromBytes() {
        let message = MIDISystemMessage.masterCoarseTuning(0x4c)

        #expect(MIDISystemMessage(statusByte: 0xf0,
                                  dataBytes: message.dataBytes ?? []) == message)
    }

    @Test
    func masterFineTuning() {
        // The default, A440, is LSB 00, MSB 40.
        #expect(MIDISystemMessage.masterFineTuning(8_192).dataBytes == [0x7f, 0x7f, 0x04, 0x03, 0x00, 0x40, 0xf7])
        #expect(MIDISystemMessage.masterFineTuning(16_383).dataBytes == [0x7f, 0x7f, 0x04, 0x03, 0x7f, 0x7f, 0xf7])
        #expect(MIDISystemMessage.masterFineTuning(1).dataBytes == [0x7f, 0x7f, 0x04, 0x03, 0x01, 0x00, 0xf7])
    }

    @Test
    func masterFineTuning_parsesFromBytes() {
        let message = MIDISystemMessage.masterFineTuning(12_345)

        #expect(MIDISystemMessage(statusByte: 0xf0,
                                  dataBytes: message.dataBytes ?? []) == message)
    }

    @Test
    func masterVolume() {
        #expect(MIDISystemMessage.masterVolume(16_383).dataBytes == [0x7f, 0x7f, 0x04, 0x01, 0x7f, 0x7f, 0xf7])
        #expect(MIDISystemMessage.masterVolume(0).dataBytes == [0x7f, 0x7f, 0x04, 0x01, 0x00, 0x00, 0xf7])
        #expect(MIDISystemMessage.masterVolume(128).dataBytes == [0x7f, 0x7f, 0x04, 0x01, 0x00, 0x01, 0xf7])
    }

    @Test
    func masterVolume_parsesFromBytes() {
        let message = MIDISystemMessage.masterVolume(12_345)

        #expect(MIDISystemMessage(statusByte: 0xf0,
                                  dataBytes: message.dataBytes ?? []) == message)
    }
}
