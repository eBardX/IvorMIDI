// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDIChannelMessageTests {
}

// MARK: -

extension MIDIChannelMessageTests {
    @Test
    func test_channel() {
        let msg = MIDIChannelMessage(statusByte: 0x90,
                                     dataBytes: [0x3C, 0x64])

        #expect(msg?.channel.uintValue == 1)

        let msg5 = MIDIChannelMessage(statusByte: 0x94,
                                      dataBytes: [0x3C, 0x64])

        #expect(msg5?.channel.uintValue == 5)
    }

    @Test
    func test_dataBytes_channelPressure() {
        let msg = MIDIChannelMessage(statusByte: 0xD0,
                                     dataBytes: [0x40])

        #expect(msg?.dataBytes == [0x40])
    }

    @Test
    func test_dataBytes_controlChange() {
        let msg = MIDIChannelMessage(statusByte: 0xB0,
                                     dataBytes: [0x07, 0x64])

        #expect(msg?.dataBytes == [0x07, 0x64])
    }

    @Test
    func test_dataBytes_noteOff() {
        let msg = MIDIChannelMessage(statusByte: 0x80,
                                     dataBytes: [0x3C, 0x40])

        #expect(msg?.dataBytes == [0x3C, 0x40])
    }

    @Test
    func test_dataBytes_noteOn() {
        let msg = MIDIChannelMessage(statusByte: 0x90,
                                     dataBytes: [0x3C, 0x64])

        #expect(msg?.dataBytes == [0x3C, 0x64])
    }

    @Test
    func test_dataBytes_pitchBendChange() {
        let msg = MIDIChannelMessage(statusByte: 0xE0,
                                     dataBytes: [0x00, 0x40])

        #expect(msg?.dataBytes == [0x00, 0x40])
    }

    @Test
    func test_dataBytes_polyphonicPressure() {
        let msg = MIDIChannelMessage(statusByte: 0xA0,
                                     dataBytes: [0x3C, 0x40])

        #expect(msg?.dataBytes == [0x3C, 0x40])
    }

    @Test
    func test_dataBytes_programChange() {
        let msg = MIDIChannelMessage(statusByte: 0xC0,
                                     dataBytes: [0x05])

        #expect(msg?.dataBytes == [0x05])
    }

    @Test
    func test_expectedDataByteCount() {
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0x80) == 2)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0x90) == 2)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xA0) == 2)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xB0) == 2)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xC0) == 1)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xD0) == 1)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xE0) == 2)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xF0) == nil)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0x70) == nil)
    }

    @Test
    func test_init_channelPressure() {
        let msg = MIDIChannelMessage(statusByte: 0xD0,
                                     dataBytes: [0x40])

        #expect(msg != nil)

        if case let .channelPressure(channel, velocity) = msg {
            #expect(channel.uintValue == 1)
            #expect(velocity.uintValue == 64)
        } else {
            Issue.record("Expected channelPressure")
        }
    }

    @Test
    func test_init_controlChange() {
        let msg = MIDIChannelMessage(statusByte: 0xB0,
                                     dataBytes: [0x07, 0x64])

        #expect(msg != nil)

        if case let .controlChange(channel, controller, value) = msg {
            #expect(channel.uintValue == 1)
            #expect(controller.uintValue == 7)
            #expect(value.uintValue == 100)
        } else {
            Issue.record("Expected controlChange")
        }
    }

    @Test
    func test_init_invalid_dataByteTooHigh() {
        #expect(MIDIChannelMessage(statusByte: 0x90,
                                   dataBytes: [0x80, 0x64]) == nil)
    }

    @Test
    func test_init_invalid_statusByte() {
        #expect(MIDIChannelMessage(statusByte: 0xF0,
                                   dataBytes: [0x00, 0x00]) == nil)
    }

    @Test
    func test_init_invalid_wrongDataByteCount() {
        #expect(MIDIChannelMessage(statusByte: 0x90,
                                   dataBytes: [0x3C]) == nil)
        #expect(MIDIChannelMessage(statusByte: 0xC0,
                                   dataBytes: [0x00, 0x00]) == nil)
    }

    @Test
    func test_init_noteOff() {
        let msg = MIDIChannelMessage(statusByte: 0x80,
                                     dataBytes: [0x3C, 0x40])

        #expect(msg != nil)

        if case let .noteOff(channel, note, velocity) = msg {
            #expect(channel.uintValue == 1)
            #expect(note.uintValue == 60)
            #expect(velocity.uintValue == 64)
        } else {
            Issue.record("Expected noteOff")
        }
    }

    @Test
    func test_init_noteOn() {
        let msg = MIDIChannelMessage(statusByte: 0x93,
                                     dataBytes: [0x3C, 0x64])

        #expect(msg != nil)

        if case let .noteOn(channel, note, velocity) = msg {
            #expect(channel.uintValue == 4)
            #expect(note.uintValue == 60)
            #expect(velocity.uintValue == 100)
        } else {
            Issue.record("Expected noteOn")
        }
    }

    @Test
    func test_init_pitchBendChange() {
        let msg = MIDIChannelMessage(statusByte: 0xE0,
                                     dataBytes: [0x00, 0x40])

        #expect(msg != nil)

        if case .pitchBendChange = msg {
        } else {
            Issue.record("Expected pitchBendChange")
        }
    }

    @Test
    func test_init_polyphonicPressure() {
        let msg = MIDIChannelMessage(statusByte: 0xA0,
                                     dataBytes: [0x3C, 0x40])

        #expect(msg != nil)

        if case let .polyphonicPressure(channel, note, pressure) = msg {
            #expect(channel.uintValue == 1)
            #expect(note.uintValue == 60)
            #expect(pressure.uintValue == 64)
        } else {
            Issue.record("Expected polyphonicPressure")
        }
    }

    @Test
    func test_init_programChange() {
        let msg = MIDIChannelMessage(statusByte: 0xC0,
                                     dataBytes: [0x05])

        #expect(msg != nil)

        if case let .programChange(channel, program) = msg {
            #expect(channel.uintValue == 1)
            #expect(program.uintValue == 5)
        } else {
            Issue.record("Expected programChange")
        }
    }

    @Test
    func test_isModeMessage() {
        #expect(MIDIChannelMessage.isModeMessage(0xB0, [121, 0]))
        #expect(MIDIChannelMessage.isModeMessage(0xB0, [127, 0]))
        #expect(!MIDIChannelMessage.isModeMessage(0xB0, [120, 0]))
        #expect(!MIDIChannelMessage.isModeMessage(0x90, [121, 0]))
        #expect(!MIDIChannelMessage.isModeMessage(0xB0, []))
    }

    @Test
    func test_isVoiceMessage() {
        #expect(MIDIChannelMessage.isVoiceMessage(0x90, [0x3C, 0x64]))
        #expect(MIDIChannelMessage.isVoiceMessage(0x80, [0x3C, 0x40]))
        #expect(MIDIChannelMessage.isVoiceMessage(0xC0, [0x05]))
        #expect(!MIDIChannelMessage.isVoiceMessage(0xB0, [121, 0]))
        #expect(!MIDIChannelMessage.isVoiceMessage(0xF0, [0x00]))
    }

    @Test
    func test_statusByte() {
        #expect(MIDIChannelMessage(statusByte: 0x80, dataBytes: [0x3C, 0x40])?.statusByte == 0x80)
        #expect(MIDIChannelMessage(statusByte: 0x90, dataBytes: [0x3C, 0x64])?.statusByte == 0x90)
        #expect(MIDIChannelMessage(statusByte: 0xA0, dataBytes: [0x3C, 0x40])?.statusByte == 0xA0)
        #expect(MIDIChannelMessage(statusByte: 0xB0, dataBytes: [0x07, 0x64])?.statusByte == 0xB0)
        #expect(MIDIChannelMessage(statusByte: 0xC0, dataBytes: [0x05])?.statusByte == 0xC0)
        #expect(MIDIChannelMessage(statusByte: 0xD0, dataBytes: [0x40])?.statusByte == 0xD0)
        #expect(MIDIChannelMessage(statusByte: 0xE0, dataBytes: [0x00, 0x40])?.statusByte == 0xE0)
    }
}
