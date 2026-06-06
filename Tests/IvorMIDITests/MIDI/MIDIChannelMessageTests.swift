// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDIChannelMessageTests {
}

// MARK: -

extension MIDIChannelMessageTests {
    @Test
    func channel() {
        let msg = MIDIChannelMessage(statusByte: 0x90,
                                     dataBytes: [0x3c, 0x64])

        #expect(msg?.channel.uintValue == 1)

        let msg5 = MIDIChannelMessage(statusByte: 0x94,
                                      dataBytes: [0x3c, 0x64])

        #expect(msg5?.channel.uintValue == 5)
    }

    @Test
    func dataBytes_channelPressure() {
        let msg = MIDIChannelMessage(statusByte: 0xd0,
                                     dataBytes: [0x40])

        #expect(msg?.dataBytes == [0x40])
    }

    @Test
    func dataBytes_controlChange() {
        let msg = MIDIChannelMessage(statusByte: 0xb0,
                                     dataBytes: [0x07, 0x64])

        #expect(msg?.dataBytes == [0x07, 0x64])
    }

    @Test
    func dataBytes_noteOff() {
        let msg = MIDIChannelMessage(statusByte: 0x80,
                                     dataBytes: [0x3c, 0x40])

        #expect(msg?.dataBytes == [0x3c, 0x40])
    }

    @Test
    func dataBytes_noteOn() {
        let msg = MIDIChannelMessage(statusByte: 0x90,
                                     dataBytes: [0x3c, 0x64])

        #expect(msg?.dataBytes == [0x3c, 0x64])
    }

    @Test
    func dataBytes_pitchBendChange() {
        let msg = MIDIChannelMessage(statusByte: 0xe0,
                                     dataBytes: [0x00, 0x40])

        #expect(msg?.dataBytes == [0x00, 0x40])
    }

    @Test
    func dataBytes_polyphonicPressure() {
        let msg = MIDIChannelMessage(statusByte: 0xa0,
                                     dataBytes: [0x3c, 0x40])

        #expect(msg?.dataBytes == [0x3c, 0x40])
    }

    @Test
    func dataBytes_programChange() {
        let msg = MIDIChannelMessage(statusByte: 0xc0,
                                     dataBytes: [0x05])

        #expect(msg?.dataBytes == [0x05])
    }

    @Test
    func equality() {
        let msg1 = MIDIChannelMessage(statusByte: 0x90, dataBytes: [0x3c, 0x64])!  // swiftlint:disable:this force_unwrapping
        let msg2 = MIDIChannelMessage(statusByte: 0x90, dataBytes: [0x3c, 0x64])!  // swiftlint:disable:this force_unwrapping

        #expect(msg1 == msg2)
    }

    @Test
    func expectedDataByteCount() {
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0x80) == 2)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0x90) == 2)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xa0) == 2)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xb0) == 2)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xc0) == 1)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xd0) == 1)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xe0) == 2)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0xf0) == nil)
        #expect(MIDIChannelMessage.expectedDataByteCount(for: 0x70) == nil)
    }

    @Test
    func inequality_differentMessageType() {
        let noteOn  = MIDIChannelMessage(statusByte: 0x90, dataBytes: [0x3c, 0x64])!   // swiftlint:disable:this force_unwrapping
        let noteOff = MIDIChannelMessage(statusByte: 0x80, dataBytes: [0x3c, 0x40])!   // swiftlint:disable:this force_unwrapping

        #expect(noteOn != noteOff)
    }

    @Test
    func inequality_differentNote() {
        let msg1 = MIDIChannelMessage(statusByte: 0x90, dataBytes: [0x3c, 0x64])!  // swiftlint:disable:this force_unwrapping
        let msg2 = MIDIChannelMessage(statusByte: 0x90, dataBytes: [0x3d, 0x64])!  // swiftlint:disable:this force_unwrapping

        #expect(msg1 != msg2)
    }

    @Test
    func init_channelPressure() {
        let msg = MIDIChannelMessage(statusByte: 0xd0,
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
    func init_controlChange() {
        let msg = MIDIChannelMessage(statusByte: 0xb0,
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
    func init_invalid_dataByteTooHigh() {
        #expect(MIDIChannelMessage(statusByte: 0x90,
                                   dataBytes: [0x80, 0x64]) == nil)
    }

    @Test
    func init_invalid_statusByte() {
        #expect(MIDIChannelMessage(statusByte: 0xf0,
                                   dataBytes: [0x00, 0x00]) == nil)
    }

    @Test
    func init_invalid_wrongDataByteCount() {
        #expect(MIDIChannelMessage(statusByte: 0x90,
                                   dataBytes: [0x3c]) == nil)
        #expect(MIDIChannelMessage(statusByte: 0xc0,
                                   dataBytes: [0x00, 0x00]) == nil)
    }

    @Test
    func init_noteOff() {
        let msg = MIDIChannelMessage(statusByte: 0x80,
                                     dataBytes: [0x3c, 0x40])

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
    func init_noteOn() {
        let msg = MIDIChannelMessage(statusByte: 0x93,
                                     dataBytes: [0x3c, 0x64])

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
    func init_pitchBendChange() {
        let msg = MIDIChannelMessage(statusByte: 0xe0,
                                     dataBytes: [0x00, 0x40])

        #expect(msg != nil)

        if case .pitchBendChange = msg {
        } else {
            Issue.record("Expected pitchBendChange")
        }
    }

    @Test
    func init_polyphonicPressure() {
        let msg = MIDIChannelMessage(statusByte: 0xa0,
                                     dataBytes: [0x3c, 0x40])

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
    func init_programChange() {
        let msg = MIDIChannelMessage(statusByte: 0xc0,
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
    func isModeMessage() {
        #expect(MIDIChannelMessage.isModeMessage(0xb0, [121, 0]))
        #expect(MIDIChannelMessage.isModeMessage(0xb0, [127, 0]))
        #expect(!MIDIChannelMessage.isModeMessage(0xb0, [120, 0]))
        #expect(!MIDIChannelMessage.isModeMessage(0x90, [121, 0]))
        #expect(!MIDIChannelMessage.isModeMessage(0xb0, []))
    }

    @Test
    func isVoiceMessage() {
        #expect(MIDIChannelMessage.isVoiceMessage(0x90, [0x3c, 0x64]))
        #expect(MIDIChannelMessage.isVoiceMessage(0x80, [0x3c, 0x40]))
        #expect(MIDIChannelMessage.isVoiceMessage(0xc0, [0x05]))
        #expect(!MIDIChannelMessage.isVoiceMessage(0xb0, [121, 0]))
        #expect(!MIDIChannelMessage.isVoiceMessage(0xf0, [0x00]))
    }

    @Test
    func statusByte() {
        #expect(MIDIChannelMessage(statusByte: 0x80, dataBytes: [0x3c, 0x40])?.statusByte == 0x80)
        #expect(MIDIChannelMessage(statusByte: 0x90, dataBytes: [0x3c, 0x64])?.statusByte == 0x90)
        #expect(MIDIChannelMessage(statusByte: 0xa0, dataBytes: [0x3c, 0x40])?.statusByte == 0xa0)
        #expect(MIDIChannelMessage(statusByte: 0xb0, dataBytes: [0x07, 0x64])?.statusByte == 0xb0)
        #expect(MIDIChannelMessage(statusByte: 0xc0, dataBytes: [0x05])?.statusByte == 0xc0)
        #expect(MIDIChannelMessage(statusByte: 0xd0, dataBytes: [0x40])?.statusByte == 0xd0)
        #expect(MIDIChannelMessage(statusByte: 0xe0, dataBytes: [0x00, 0x40])?.statusByte == 0xe0)
    }
}
