// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDISystemMessageTests {
}

// MARK: -

extension MIDISystemMessageTests {
    @Test
    func test_dataBytes_activeSensing() {
        let msg = MIDISystemMessage(statusByte: 0xFE, dataBytes: [])

        #expect(msg?.dataBytes?.isEmpty == true)
    }

    @Test
    func test_dataBytes_mtcQuarterFrame() {
        let msg = MIDISystemMessage(statusByte: 0xF1, dataBytes: [0x30])

        #expect(msg?.dataBytes == [0x30])
    }

    @Test
    func test_dataBytes_songPosition() {
        let msg = MIDISystemMessage(statusByte: 0xF2, dataBytes: [0x00, 0x01])

        #expect(msg?.dataBytes == [0x00, 0x01])
    }

    @Test
    func test_dataBytes_systemExclusive() {
        let msg = MIDISystemMessage(statusByte: 0xF0, dataBytes: [0x7E, 0x7F, 0xF7])

        #expect(msg?.dataBytes == [0x7E, 0x7F, 0xF7])
    }

    @Test
    func test_init_activeSensing() {
        let msg = MIDISystemMessage(statusByte: 0xFE, dataBytes: [])

        #expect(msg != nil)

        if case .activeSensing = msg {
        } else {
            Issue.record("Expected activeSensing")
        }
    }

    @Test
    func test_init_continue() {
        let msg = MIDISystemMessage(statusByte: 0xFB, dataBytes: [])

        #expect(msg != nil)

        if case .continue = msg {
        } else {
            Issue.record("Expected continue")
        }
    }

    @Test
    func test_init_eox() {
        let msg = MIDISystemMessage(statusByte: 0xF7, dataBytes: [])

        #expect(msg != nil)

        if case .eox = msg {
        } else {
            Issue.record("Expected eox")
        }
    }

    @Test
    func test_init_invalid_commonWithData() {
        #expect(MIDISystemMessage(statusByte: 0xF6, dataBytes: [0x00]) == nil)
    }

    @Test
    func test_init_invalid_nonSystemStatus() {
        #expect(MIDISystemMessage(statusByte: 0x90, dataBytes: []) == nil)
    }

    @Test
    func test_init_invalid_realTimeWithData() {
        #expect(MIDISystemMessage(statusByte: 0xF8, dataBytes: [0x00]) == nil)
    }

    @Test
    func test_init_invalid_systemExclusiveNoEox() {
        #expect(MIDISystemMessage(statusByte: 0xF0, dataBytes: [0x7E, 0x7F]) == nil)
    }

    @Test
    func test_init_invalid_systemExclusiveTooShort() {
        #expect(MIDISystemMessage(statusByte: 0xF0, dataBytes: [0xF7]) == nil)
    }

    @Test
    func test_init_mtcQuarterFrame() {
        let msg = MIDISystemMessage(statusByte: 0xF1, dataBytes: [0x30])

        #expect(msg != nil)

        if case let .mtcQuarterFrame(value) = msg {
            #expect(value.uintValue == 48)
        } else {
            Issue.record("Expected mtcQuarterFrame")
        }
    }

    @Test
    func test_init_songPosition() {
        let msg = MIDISystemMessage(statusByte: 0xF2, dataBytes: [0x00, 0x01])

        #expect(msg != nil)

        if case .songPosition = msg {
        } else {
            Issue.record("Expected songPosition")
        }
    }

    @Test
    func test_init_songSelect() {
        let msg = MIDISystemMessage(statusByte: 0xF3, dataBytes: [0x05])

        #expect(msg != nil)

        if case let .songSelect(song) = msg {
            #expect(song.uintValue == 5)
        } else {
            Issue.record("Expected songSelect")
        }
    }

    @Test
    func test_init_start() {
        let msg = MIDISystemMessage(statusByte: 0xFA, dataBytes: [])

        #expect(msg != nil)

        if case .start = msg {
        } else {
            Issue.record("Expected start")
        }
    }

    @Test
    func test_init_stop() {
        let msg = MIDISystemMessage(statusByte: 0xFC, dataBytes: [])

        #expect(msg != nil)

        if case .stop = msg {
        } else {
            Issue.record("Expected stop")
        }
    }

    @Test
    func test_init_systemExclusive() {
        let msg = MIDISystemMessage(statusByte: 0xF0,
                                    dataBytes: [0x7E, 0x7F, 0xF7])

        #expect(msg != nil)

        if case let .systemExclusive(data) = msg {
            #expect(data == [0x7E, 0x7F, 0xF7])
        } else {
            Issue.record("Expected systemExclusive")
        }
    }

    @Test
    func test_init_systemReset() {
        let msg = MIDISystemMessage(statusByte: 0xFF, dataBytes: [])

        #expect(msg != nil)

        if case .systemReset = msg {
        } else {
            Issue.record("Expected systemReset")
        }
    }

    @Test
    func test_init_timingClock() {
        let msg = MIDISystemMessage(statusByte: 0xF8, dataBytes: [])

        #expect(msg != nil)

        if case .timingClock = msg {
        } else {
            Issue.record("Expected timingClock")
        }
    }

    @Test
    func test_init_tuneRequest() {
        let msg = MIDISystemMessage(statusByte: 0xF6, dataBytes: [])

        #expect(msg != nil)

        if case .tuneRequest = msg {
        } else {
            Issue.record("Expected tuneRequest")
        }
    }

    @Test
    func test_isCommonMessage() {
        #expect(!MIDISystemMessage.isCommonMessage(0xF0))
        #expect(MIDISystemMessage.isCommonMessage(0xF1))
        #expect(MIDISystemMessage.isCommonMessage(0xF6))
        #expect(MIDISystemMessage.isCommonMessage(0xF7))
        #expect(!MIDISystemMessage.isCommonMessage(0xF8))
    }

    @Test
    func test_isExclusiveMessage() {
        #expect(MIDISystemMessage.isExclusiveMessage(0xF0))
        #expect(!MIDISystemMessage.isExclusiveMessage(0xF1))
        #expect(!MIDISystemMessage.isExclusiveMessage(0xF7))
    }

    @Test
    func test_isRealTimeMessage() {
        #expect(!MIDISystemMessage.isRealTimeMessage(0xF7))
        #expect(MIDISystemMessage.isRealTimeMessage(0xF8))
        #expect(MIDISystemMessage.isRealTimeMessage(0xFA))
        #expect(MIDISystemMessage.isRealTimeMessage(0xFF))
    }

    @Test
    func test_statusByte() {
        #expect(MIDISystemMessage.activeSensing.statusByte == 0xFE)
        #expect(MIDISystemMessage.continue.statusByte == 0xFB)
        #expect(MIDISystemMessage.eox.statusByte == 0xF7)
        #expect(MIDISystemMessage.start.statusByte == 0xFA)
        #expect(MIDISystemMessage.stop.statusByte == 0xFC)
        #expect(MIDISystemMessage.systemReset.statusByte == 0xFF)
        #expect(MIDISystemMessage.timingClock.statusByte == 0xF8)
        #expect(MIDISystemMessage.tuneRequest.statusByte == 0xF6)
    }
}
