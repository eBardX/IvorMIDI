// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDISystemMessageTests {
}

// MARK: -

extension MIDISystemMessageTests {
    @Test
    func dataBytes_activeSensing() {
        let msg = MIDISystemMessage(statusByte: 0xfe, dataBytes: [])

        #expect(msg?.dataBytes?.isEmpty == true)
    }

    @Test
    func dataBytes_mtcQuarterFrame() {
        let msg = MIDISystemMessage(statusByte: 0xf1, dataBytes: [0x30])

        #expect(msg?.dataBytes == [0x30])
    }

    @Test
    func dataBytes_songPosition() {
        let msg = MIDISystemMessage(statusByte: 0xf2, dataBytes: [0x00, 0x01])

        #expect(msg?.dataBytes == [0x00, 0x01])
    }

    @Test
    func dataBytes_systemExclusive() {
        let msg = MIDISystemMessage(statusByte: 0xf0, dataBytes: [0x7e, 0x7f, 0xf7])

        #expect(msg?.dataBytes == [0x7e, 0x7f, 0xf7])
    }

    @Test
    func init_activeSensing() {
        let msg = MIDISystemMessage(statusByte: 0xfe, dataBytes: [])

        #expect(msg != nil)

        if case .activeSensing = msg {
        } else {
            Issue.record("Expected activeSensing")
        }
    }

    @Test
    func init_continue() {
        let msg = MIDISystemMessage(statusByte: 0xfb, dataBytes: [])

        #expect(msg != nil)

        if case .continue = msg {
        } else {
            Issue.record("Expected continue")
        }
    }

    @Test
    func init_eox() {
        let msg = MIDISystemMessage(statusByte: 0xf7, dataBytes: [])

        #expect(msg != nil)

        if case .eox = msg {
        } else {
            Issue.record("Expected eox")
        }
    }

    @Test
    func init_invalid_commonWithData() {
        #expect(MIDISystemMessage(statusByte: 0xf6, dataBytes: [0x00]) == nil)
    }

    @Test
    func init_invalid_nonSystemStatus() {
        #expect(MIDISystemMessage(statusByte: 0x90, dataBytes: []) == nil)
    }

    @Test
    func init_invalid_realTimeWithData() {
        #expect(MIDISystemMessage(statusByte: 0xf8, dataBytes: [0x00]) == nil)
    }

    @Test
    func init_invalid_systemExclusiveNoEox() {
        #expect(MIDISystemMessage(statusByte: 0xf0, dataBytes: [0x7e, 0x7f]) == nil)
    }

    @Test
    func init_invalid_systemExclusiveTooShort() {
        #expect(MIDISystemMessage(statusByte: 0xf0, dataBytes: [0xf7]) == nil)
    }

    @Test
    func init_mtcQuarterFrame() {
        let msg = MIDISystemMessage(statusByte: 0xf1, dataBytes: [0x30])

        #expect(msg != nil)

        if case let .mtcQuarterFrame(value) = msg {
            #expect(value.uintValue == 48)
        } else {
            Issue.record("Expected mtcQuarterFrame")
        }
    }

    @Test
    func init_songPosition() {
        let msg = MIDISystemMessage(statusByte: 0xf2, dataBytes: [0x00, 0x01])

        #expect(msg != nil)

        if case .songPosition = msg {
        } else {
            Issue.record("Expected songPosition")
        }
    }

    @Test
    func init_songSelect() {
        let msg = MIDISystemMessage(statusByte: 0xf3, dataBytes: [0x05])

        #expect(msg != nil)

        if case let .songSelect(song) = msg {
            #expect(song.uintValue == 5)
        } else {
            Issue.record("Expected songSelect")
        }
    }

    @Test
    func init_start() {
        let msg = MIDISystemMessage(statusByte: 0xfa, dataBytes: [])

        #expect(msg != nil)

        if case .start = msg {
        } else {
            Issue.record("Expected start")
        }
    }

    @Test
    func init_stop() {
        let msg = MIDISystemMessage(statusByte: 0xfc, dataBytes: [])

        #expect(msg != nil)

        if case .stop = msg {
        } else {
            Issue.record("Expected stop")
        }
    }

    @Test
    func init_systemExclusive() {
        let msg = MIDISystemMessage(statusByte: 0xf0,
                                    dataBytes: [0x7e, 0x7f, 0xf7])

        #expect(msg != nil)

        if case let .systemExclusive(data) = msg {
            #expect(data == [0x7e, 0x7f, 0xf7])
        } else {
            Issue.record("Expected systemExclusive")
        }
    }

    @Test
    func init_systemReset() {
        let msg = MIDISystemMessage(statusByte: 0xff, dataBytes: [])

        #expect(msg != nil)

        if case .systemReset = msg {
        } else {
            Issue.record("Expected systemReset")
        }
    }

    @Test
    func init_timingClock() {
        let msg = MIDISystemMessage(statusByte: 0xf8, dataBytes: [])

        #expect(msg != nil)

        if case .timingClock = msg {
        } else {
            Issue.record("Expected timingClock")
        }
    }

    @Test
    func init_tuneRequest() {
        let msg = MIDISystemMessage(statusByte: 0xf6, dataBytes: [])

        #expect(msg != nil)

        if case .tuneRequest = msg {
        } else {
            Issue.record("Expected tuneRequest")
        }
    }

    @Test
    func isCommonMessage() {
        #expect(!MIDISystemMessage.isCommonMessage(0xf0))
        #expect(MIDISystemMessage.isCommonMessage(0xf1))
        #expect(MIDISystemMessage.isCommonMessage(0xf6))
        #expect(MIDISystemMessage.isCommonMessage(0xf7))
        #expect(!MIDISystemMessage.isCommonMessage(0xf8))
    }

    @Test
    func isExclusiveMessage() {
        #expect(MIDISystemMessage.isExclusiveMessage(0xf0))
        #expect(!MIDISystemMessage.isExclusiveMessage(0xf1))
        #expect(!MIDISystemMessage.isExclusiveMessage(0xf7))
    }

    @Test
    func isRealTimeMessage() {
        #expect(!MIDISystemMessage.isRealTimeMessage(0xf7))
        #expect(MIDISystemMessage.isRealTimeMessage(0xf8))
        #expect(MIDISystemMessage.isRealTimeMessage(0xfa))
        #expect(MIDISystemMessage.isRealTimeMessage(0xff))
    }

    @Test
    func statusByte() {
        #expect(MIDISystemMessage.activeSensing.statusByte == 0xfe)
        #expect(MIDISystemMessage.continue.statusByte == 0xfb)
        #expect(MIDISystemMessage.eox.statusByte == 0xf7)
        #expect(MIDISystemMessage.start.statusByte == 0xfa)
        #expect(MIDISystemMessage.stop.statusByte == 0xfc)
        #expect(MIDISystemMessage.systemReset.statusByte == 0xff)
        #expect(MIDISystemMessage.timingClock.statusByte == 0xf8)
        #expect(MIDISystemMessage.tuneRequest.statusByte == 0xf6)
    }
}
