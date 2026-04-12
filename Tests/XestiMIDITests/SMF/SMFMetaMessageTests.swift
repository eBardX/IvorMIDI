// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFMetaMessageTests {
}

// MARK: -

extension SMFMetaMessageTests {
    @Test
    func test_dataBytes_endOfTrack() {
        #expect(SMFMetaMessage.endOfTrack.dataBytes?.isEmpty == true)
    }

    @Test
    func test_init_copyright() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x02,
                                 dataBytes: Array("(c)".utf8))

        #expect(msg != nil)

        if case let .copyright(text) = msg {
            #expect(text.stringValue == "(c)")
        } else {
            Issue.record("Expected copyright")
        }
    }

    @Test
    func test_init_cuePoint() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x07,
                                 dataBytes: Array("cue".utf8))

        #expect(msg != nil)

        if case .cuePoint = msg {
        } else {
            Issue.record("Expected cuePoint")
        }
    }

    @Test
    func test_init_deviceName() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x09,
                                 dataBytes: Array("dev".utf8))

        #expect(msg != nil)

        if case .deviceName = msg {
        } else {
            Issue.record("Expected deviceName")
        }
    }

    @Test
    func test_init_endOfTrack() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x2F,
                                 dataBytes: [])

        #expect(msg != nil)

        if case .endOfTrack = msg {
        } else {
            Issue.record("Expected endOfTrack")
        }
    }

    @Test
    func test_init_instrumentName() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x04,
                                 dataBytes: Array("Piano".utf8))

        #expect(msg != nil)

        if case .instrumentName = msg {
        } else {
            Issue.record("Expected instrumentName")
        }
    }

    @Test
    func test_init_invalid_statusByte() {
        #expect(SMFMetaMessage(statusByte: 0xFE,
                               typeByte: 0x2F,
                               dataBytes: []) == nil)
    }

    @Test
    func test_init_invalid_typeByte() {
        #expect(SMFMetaMessage(statusByte: 0xFF,
                               typeByte: 0x10,
                               dataBytes: []) == nil)
    }

    @Test
    func test_init_keySignature() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x59,
                                 dataBytes: [0x00, 0x00])

        #expect(msg != nil)

        if case let .keySignature(keySig) = msg {
            #expect(keySig == .cMajor)
        } else {
            Issue.record("Expected keySignature")
        }
    }

    @Test
    func test_init_lyric() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x05,
                                 dataBytes: Array("la".utf8))

        #expect(msg != nil)

        if case .lyric = msg {
        } else {
            Issue.record("Expected lyric")
        }
    }

    @Test
    func test_init_marker() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x06,
                                 dataBytes: Array("A".utf8))

        #expect(msg != nil)

        if case .marker = msg {
        } else {
            Issue.record("Expected marker")
        }
    }

    @Test
    func test_init_midiChannelPrefix() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x20,
                                 dataBytes: [0x00])

        #expect(msg != nil)

        if case let .midiChannelPrefix(channel) = msg {
            #expect(channel.uintValue == 1)
        } else {
            Issue.record("Expected midiChannelPrefix")
        }
    }

    @Test
    func test_init_midiPort() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x21,
                                 dataBytes: [0x00])

        #expect(msg != nil)

        if case let .midiPort(port) = msg {
            #expect(port.uintValue == 0)
        } else {
            Issue.record("Expected midiPort")
        }
    }

    @Test
    func test_init_programName() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x08,
                                 dataBytes: Array("pgm".utf8))

        #expect(msg != nil)

        if case .programName = msg {
        } else {
            Issue.record("Expected programName")
        }
    }

    @Test
    func test_init_sequenceNumber() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x00,
                                 dataBytes: [0x00, 0x01])

        #expect(msg != nil)

        if case let .sequenceNumber(seqNum) = msg {
            #expect(seqNum.uintValue == 1)
        } else {
            Issue.record("Expected sequenceNumber")
        }
    }

    @Test
    func test_init_sequenceTrackName() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x03,
                                 dataBytes: Array("Track 1".utf8))

        #expect(msg != nil)

        if case let .sequenceTrackName(text) = msg {
            #expect(text.stringValue == "Track 1")
        } else {
            Issue.record("Expected sequenceTrackName")
        }
    }

    @Test
    func test_init_sequencerSpecific() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x7F,
                                 dataBytes: [0x01, 0x02, 0x03])

        #expect(msg != nil)

        if case let .sequencerSpecific(data) = msg {
            #expect(data == [0x01, 0x02, 0x03])
        } else {
            Issue.record("Expected sequencerSpecific")
        }
    }

    @Test
    func test_init_sequencerSpecific_empty() {
        #expect(SMFMetaMessage(statusByte: 0xFF,
                               typeByte: 0x7F,
                               dataBytes: []) == nil)
    }

    @Test
    func test_init_smpteOffset() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x54,
                                 dataBytes: [0x01, 0x02, 0x03, 0x04, 0x05])

        #expect(msg != nil)

        if case let .smpteOffset(time) = msg {
            #expect(time.hour == 1)
            #expect(time.minute == 2)
        } else {
            Issue.record("Expected smpteOffset")
        }
    }

    @Test
    func test_init_tempo() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x51,
                                 dataBytes: [0x07, 0xA1, 0x20])

        #expect(msg != nil)

        if case let .tempo(tempo) = msg {
            #expect(tempo.uintValue == 500_000)
        } else {
            Issue.record("Expected tempo")
        }
    }

    @Test
    func test_init_text() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x01,
                                 dataBytes: Array("hello".utf8))

        #expect(msg != nil)

        if case let .text(text) = msg {
            #expect(text.stringValue == "hello")
        } else {
            Issue.record("Expected text")
        }
    }

    @Test
    func test_init_timeSignature() {
        let msg = SMFMetaMessage(statusByte: 0xFF,
                                 typeByte: 0x58,
                                 dataBytes: [0x04, 0x02, 0x18, 0x08])

        #expect(msg != nil)

        if case let .timeSignature(timeSig) = msg {
            #expect(timeSig.numerator == 4)
            #expect(timeSig.denominator == 2)
        } else {
            Issue.record("Expected timeSignature")
        }
    }

    @Test
    func test_statusByte() {
        #expect(SMFMetaMessage.endOfTrack.statusByte == 0xFF)
    }

    @Test
    func test_typeByte() {
        #expect(SMFMetaMessage.endOfTrack.typeByte == 0x2F)

        let text = SMFMetaMessage(statusByte: 0xFF,
                                  typeByte: 0x01,
                                  dataBytes: Array("hi".utf8))

        #expect(text?.typeByte == 0x01)
    }
}
