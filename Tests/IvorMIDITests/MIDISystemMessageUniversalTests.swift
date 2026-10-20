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

    @Test
    func scaleOctaveTuning() {
        let offsets: [MIDIData1Value] = [0x40, 0x3e, 0x40, 0x42, 0x40, 0x40, 0x3e, 0x40, 0x3e, 0x40, 0x42, 0x40]
        let message = MIDISystemMessage.scaleOctaveTuning(channels: [1], offsets: offsets)

        #expect(message?.dataBytes == [0x7e, 0x7f, 0x08, 0x08, 0x00, 0x00, 0x01]
                                      + [0x40, 0x3e, 0x40, 0x42, 0x40, 0x40, 0x3e, 0x40, 0x3e, 0x40, 0x42, 0x40]
                                      + [0xf7])
    }

    @Test
    func scaleOctaveTuning_channelBits() {
        let offsets = [MIDIData1Value](repeating: 0x40, count: 12)
        let channelBytes = { (channels: [MIDIChannel]) in
            MIDISystemMessage.scaleOctaveTuning(channels: channels, offsets: offsets)?.dataBytes?[4...6].map(\.self)
        }

        #expect(channelBytes([]) == [0x00, 0x00, 0x00])
        #expect(channelBytes([7]) == [0x00, 0x00, 0x40])
        #expect(channelBytes([8]) == [0x00, 0x01, 0x00])
        #expect(channelBytes([14]) == [0x00, 0x40, 0x00])
        #expect(channelBytes([15, 16]) == [0x03, 0x00, 0x00])
        #expect(channelBytes((1...16).compactMap { MIDIChannel(uintValue: $0) }) == [0x03, 0x7f, 0x7f])
    }

    @Test
    func scaleOctaveTuning_realTime() {
        let offsets = [MIDIData1Value](repeating: 0x40, count: 12)
        let message = MIDISystemMessage.scaleOctaveTuning(channels: [10], offsets: offsets, realTime: true)

        #expect(message?.dataBytes?.prefix(7) == [0x7f, 0x7f, 0x08, 0x08, 0x00, 0x04, 0x00])
    }

    @Test
    func scaleOctaveTuning_wrongOffsetCount() {
        let offsets = [MIDIData1Value](repeating: 0x40, count: 11)

        #expect(MIDISystemMessage.scaleOctaveTuning(channels: [1], offsets: offsets) == nil)
        #expect(MIDISystemMessage.scaleOctaveTuning(channels: [1], offsets: offsets + [0x40, 0x40]) == nil)
    }
}
