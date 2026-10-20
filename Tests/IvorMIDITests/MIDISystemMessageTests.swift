// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct MIDISystemMessageTests {
}

// MARK: -

extension MIDISystemMessageTests {
    @Test
    func bytesValue() {
        #expect(MIDISystemMessage.timingClock.bytesValue == [0xf8])
        #expect(MIDISystemMessage.songPosition(8_192).bytesValue == [0xf2, 0x00, 0x40])
        #expect(MIDISystemMessage.songSelect(5).bytesValue == [0xf3, 0x05])
        #expect(MIDISystemMessage.systemExclusive([0x7e, 0x7f, 0xf7]).bytesValue == [0xf0, 0x7e, 0x7f, 0xf7])
    }

    @Test
    func dataBytes_activeSensing() {
        let msg = MIDISystemMessage(statusByte: 0xfe, dataBytes: [])

        #expect(msg?.dataBytes?.isEmpty == true)
    }

    @Test
    func dataBytes_continue() {
        let msg = MIDISystemMessage(statusByte: 0xfb, dataBytes: [])

        #expect(msg?.dataBytes?.isEmpty == true)
    }

    @Test
    func dataBytes_eox() {
        let msg = MIDISystemMessage(statusByte: 0xf7, dataBytes: [])

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
    func dataBytes_songSelect() {
        let msg = MIDISystemMessage(statusByte: 0xf3, dataBytes: [0x05])

        #expect(msg?.dataBytes == [0x05])
    }

    @Test
    func dataBytes_start() {
        let msg = MIDISystemMessage(statusByte: 0xfa, dataBytes: [])

        #expect(msg?.dataBytes?.isEmpty == true)
    }

    @Test
    func dataBytes_stop() {
        let msg = MIDISystemMessage(statusByte: 0xfc, dataBytes: [])

        #expect(msg?.dataBytes?.isEmpty == true)
    }

    @Test
    func dataBytes_systemExclusive() {
        let msg = MIDISystemMessage(statusByte: 0xf0, dataBytes: [0x7e, 0x7f, 0xf7])

        #expect(msg?.dataBytes == [0x7e, 0x7f, 0xf7])
    }

    @Test
    func dataBytes_systemReset() {
        let msg = MIDISystemMessage(statusByte: 0xff, dataBytes: [])

        #expect(msg?.dataBytes?.isEmpty == true)
    }

    @Test
    func dataBytes_timingClock() {
        let msg = MIDISystemMessage(statusByte: 0xf8, dataBytes: [])

        #expect(msg?.dataBytes?.isEmpty == true)
    }

    @Test
    func dataBytes_tuneRequest() {
        let msg = MIDISystemMessage(statusByte: 0xf6, dataBytes: [])

        #expect(msg?.dataBytes?.isEmpty == true)
    }

    @Test
    func equality() {
        let msg1 = MIDISystemMessage(statusByte: 0xf1, dataBytes: [0x30])!  // swiftlint:disable:this force_unwrapping
        let msg2 = MIDISystemMessage(statusByte: 0xf1, dataBytes: [0x30])!  // swiftlint:disable:this force_unwrapping

        #expect(msg1 == msg2)
    }

    @Test
    func expectedDataByteCount() {
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xf1) == 1)
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xf2) == 2)
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xf3) == 1)
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xf6) == 0)
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xf7) == 0)
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xf8) == 0)
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xff) == 0)
    }

    @Test
    func expectedDataByteCount_matchesInit() {
        for statusByte in UInt8(0xf1)...0xff {
            guard let count = MIDISystemMessage.expectedDataByteCount(for: statusByte)
            else { continue }

            #expect(MIDISystemMessage(statusByte: statusByte,
                                      dataBytes: Array(repeating: 0, count: count)) != nil)
        }
    }

    @Test
    func expectedDataByteCount_nil() {
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0x90) == nil)  // channel status
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xf0) == nil)  // system exclusive
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xf4) == nil)  // undefined
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xf5) == nil)
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xf9) == nil)
        #expect(MIDISystemMessage.expectedDataByteCount(for: 0xfd) == nil)
    }

    @Test
    func hashable() {
        let msg1 = MIDISystemMessage(statusByte: 0xf1, dataBytes: [0x30])!  // swiftlint:disable:this force_unwrapping
        let msg2 = MIDISystemMessage(statusByte: 0xf1, dataBytes: [0x30])!  // swiftlint:disable:this force_unwrapping
        let msg3 = MIDISystemMessage.activeSensing
        let set: Set<MIDISystemMessage> = [msg1, msg2, msg3]

        #expect(msg1.hashValue == msg2.hashValue)
        #expect(set.count == 2)
    }

    @Test
    func inequality_differentCase() {
        #expect(MIDISystemMessage.activeSensing != MIDISystemMessage.timingClock)
    }

    @Test
    func inequality_differentValue() {
        let msg1 = MIDISystemMessage(statusByte: 0xf1, dataBytes: [0x30])!  // swiftlint:disable:this force_unwrapping
        let msg2 = MIDISystemMessage(statusByte: 0xf1, dataBytes: [0x31])!  // swiftlint:disable:this force_unwrapping

        #expect(msg1 != msg2)
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
    func init_bytesValue() {
        #expect(MIDISystemMessage(bytesValue: [0xf8]) == .timingClock)
        #expect(MIDISystemMessage(bytesValue: [0xf2, 0x00, 0x40]) == .songPosition(8_192))
        #expect(MIDISystemMessage(bytesValue: [0xf0, 0x7e, 0x7f, 0xf7]) == .systemExclusive([0x7e, 0x7f, 0xf7]))
    }

    @Test
    func init_bytesValue_invalid() {
        #expect(MIDISystemMessage(bytesValue: []) == nil)
        #expect(MIDISystemMessage(bytesValue: [0xf8, 0x00]) == nil)
        #expect(MIDISystemMessage(bytesValue: [0xf0, 0x7e]) == nil)
        #expect(MIDISystemMessage(bytesValue: [0x90, 0x3c, 0x64]) == nil)
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
    func init_invalid_commonInvalidDataByte() {
        #expect(MIDISystemMessage(statusByte: 0xf1, dataBytes: [0x80]) == nil)
    }

    @Test
    func init_invalid_commonReservedByte() {
        #expect(MIDISystemMessage(statusByte: 0xf4, dataBytes: []) == nil)
        #expect(MIDISystemMessage(statusByte: 0xf5, dataBytes: []) == nil)
    }

    @Test
    func init_invalid_commonWithData() {
        #expect(MIDISystemMessage(statusByte: 0xf6, dataBytes: [0x00]) == nil)
    }

    @Test
    func init_invalid_eoxWithData() {
        #expect(MIDISystemMessage(statusByte: 0xf7, dataBytes: [0x00]) == nil)
    }

    @Test
    func init_invalid_mtcQuarterFrameWrongDataByteCount() {
        #expect(MIDISystemMessage(statusByte: 0xf1, dataBytes: []) == nil)
        #expect(MIDISystemMessage(statusByte: 0xf1, dataBytes: [0x30, 0x00]) == nil)
    }

    @Test
    func init_invalid_nonSystemStatus() {
        #expect(MIDISystemMessage(statusByte: 0x90, dataBytes: []) == nil)
    }

    @Test
    func init_invalid_realTimeReservedByte() {
        #expect(MIDISystemMessage(statusByte: 0xf9, dataBytes: []) == nil)
        #expect(MIDISystemMessage(statusByte: 0xfd, dataBytes: []) == nil)
    }

    @Test
    func init_invalid_realTimeWithData() {
        #expect(MIDISystemMessage(statusByte: 0xf8, dataBytes: [0x00]) == nil)
    }

    @Test
    func init_invalid_songPositionWrongDataByteCount() {
        #expect(MIDISystemMessage(statusByte: 0xf2, dataBytes: [0x00]) == nil)
        #expect(MIDISystemMessage(statusByte: 0xf2, dataBytes: [0x00, 0x01, 0x02]) == nil)
    }

    @Test
    func init_invalid_songSelectWrongDataByteCount() {
        #expect(MIDISystemMessage(statusByte: 0xf3, dataBytes: []) == nil)
        #expect(MIDISystemMessage(statusByte: 0xf3, dataBytes: [0x05, 0x00]) == nil)
    }

    @Test
    func init_invalid_systemExclusiveNoEox() {
        #expect(MIDISystemMessage(statusByte: 0xf0, dataBytes: [0x7e, 0x7f]) == nil)
    }

    @Test
    func init_invalid_systemExclusiveNonDataByte() {
        #expect(MIDISystemMessage(statusByte: 0xf0, dataBytes: [0x80, 0xf7]) == nil)
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
    func roundTrip() throws {
        let messages: [MIDISystemMessage] = [.activeSensing,
                                             .continue,
                                             .eox,
                                             .mtcQuarterFrame(0x35),
                                             .songPosition(8_192),
                                             .songSelect(5),
                                             .start,
                                             .stop,
                                             .systemExclusive([0x7e, 0x7f, 0xf7]),
                                             .systemReset,
                                             .timingClock,
                                             .tuneRequest]

        for message in messages {
            let statusByte = try #require(message.statusByte)
            let dataBytes = try #require(message.dataBytes)

            #expect(MIDISystemMessage(statusByte: statusByte,
                                      dataBytes: dataBytes) == message)
        }
    }

    @Test
    func statusByte() {
        let mtcQuarterFrame = MIDIData1Value(uintValue: 0x30)!            // swiftlint:disable:this force_unwrapping
        let songPosition = MIDIData2Value(uintValue: 0)!                  // swiftlint:disable:this force_unwrapping
        let songSelect = MIDIData1Value(uintValue: 5)!                    // swiftlint:disable:this force_unwrapping

        #expect(MIDISystemMessage.activeSensing.statusByte == 0xfe)
        #expect(MIDISystemMessage.continue.statusByte == 0xfb)
        #expect(MIDISystemMessage.eox.statusByte == 0xf7)
        #expect(MIDISystemMessage.mtcQuarterFrame(mtcQuarterFrame).statusByte == 0xf1)
        #expect(MIDISystemMessage.songPosition(songPosition).statusByte == 0xf2)
        #expect(MIDISystemMessage.songSelect(songSelect).statusByte == 0xf3)
        #expect(MIDISystemMessage.start.statusByte == 0xfa)
        #expect(MIDISystemMessage.stop.statusByte == 0xfc)
        #expect(MIDISystemMessage.systemExclusive([0x7e, 0x7f, 0xf7]).statusByte == 0xf0)
        #expect(MIDISystemMessage.systemReset.statusByte == 0xff)
        #expect(MIDISystemMessage.timingClock.statusByte == 0xf8)
        #expect(MIDISystemMessage.tuneRequest.statusByte == 0xf6)
    }
}
