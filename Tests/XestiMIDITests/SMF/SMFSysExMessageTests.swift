// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFSysExMessageTests {
}

// MARK: -

extension SMFSysExMessageTests {
    @Test
    func test_dataBytes_escape() {
        let msg = SMFSysExMessage(statusByte: 0xF7,
                                  dataBytes: [0x01, 0x02])

        #expect(msg?.dataBytes == [0x01, 0x02])
    }

    @Test
    func test_dataBytes_systemExclusive() {
        let msg = SMFSysExMessage(statusByte: 0xF0,
                                  dataBytes: [0x7E, 0xF7])

        #expect(msg?.dataBytes == [0x7E, 0xF7])
    }

    @Test
    func test_init_escape() {
        let msg = SMFSysExMessage(statusByte: 0xF7,
                                  dataBytes: [0x01, 0x02])

        #expect(msg != nil)

        if case let .escape(data) = msg {
            #expect(data == [0x01, 0x02])
        } else {
            Issue.record("Expected escape")
        }
    }

    @Test
    func test_init_invalid_statusByte() {
        #expect(SMFSysExMessage(statusByte: 0x90,
                                dataBytes: []) == nil)
        #expect(SMFSysExMessage(statusByte: 0xFF,
                                dataBytes: []) == nil)
    }

    @Test
    func test_init_systemExclusive() {
        let msg = SMFSysExMessage(statusByte: 0xF0,
                                  dataBytes: [0x7E, 0xF7])

        #expect(msg != nil)

        if case let .systemExclusive(data) = msg {
            #expect(data == [0x7E, 0xF7])
        } else {
            Issue.record("Expected systemExclusive")
        }
    }

    @Test
    func test_statusByte_escape() {
        let msg = SMFSysExMessage.escape([0x01])

        #expect(msg.statusByte == 0xF7)
    }

    @Test
    func test_statusByte_systemExclusive() {
        let msg = SMFSysExMessage.systemExclusive([0x7E, 0xF7])

        #expect(msg.statusByte == 0xF0)
    }
}
