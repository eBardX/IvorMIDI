// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct YamahaSysExTests {
}

// MARK: -

extension YamahaSysExTests {
    @Test
    func bulkDumpData() {
        let payload = YamahaSysEx.bulkDumpPayload(channel: 1, format: 0x7e, data: [0x01, 0x02])

        #expect(YamahaSysEx.bulkDumpData(payload).map(Array.init) == [0x01, 0x02])
    }

    @Test
    func bulkDumpData_badChecksum() {
        var payload = YamahaSysEx.bulkDumpPayload(channel: 1, format: 0x7e, data: [0x01, 0x02])

        payload[payload.count - 1] ^= 0x01

        #expect(YamahaSysEx.bulkDumpData(payload) == nil)
    }

    @Test
    func bulkDumpData_badSize() {
        var payload = YamahaSysEx.bulkDumpPayload(channel: 1, format: 0x7e, data: [0x01, 0x02])

        payload[3] = 0x03

        #expect(YamahaSysEx.bulkDumpData(payload) == nil)
    }

    @Test
    func bulkDumpData_emptyData() {
        let payload = YamahaSysEx.bulkDumpPayload(channel: 1, format: 0x7e, data: [])

        #expect(payload.count == 5)
        #expect(YamahaSysEx.bulkDumpData(payload)?.isEmpty == true)
    }

    @Test
    func bulkDumpData_tooShort() {
        #expect(YamahaSysEx.bulkDumpData([0x00, 0x7e, 0x00, 0x00]) == nil)
    }

    @Test
    func bulkDumpPayload() {
        #expect(YamahaSysEx.bulkDumpPayload(channel: 3, format: 0x7e, data: [0x01, 0x02])
                == [0x02, 0x7e, 0x00, 0x02, 0x01, 0x02, 0x7d])
    }

    @Test
    func bulkDumpPayload_sizeIsTwo7BitBytes() {
        let payload = YamahaSysEx.bulkDumpPayload(channel: 1,
                                                  format: 0x7e,
                                                  data: [UInt8](repeating: 0, count: 266))

        #expect(payload[2] == 0x02)
        #expect(payload[3] == 0x0a)
    }

    @Test
    func checksum() {
        #expect(YamahaSysEx.checksum([] as [UInt8]) == 0x00)
        #expect(YamahaSysEx.checksum([0x01] as [UInt8]) == 0x7f)
        #expect(YamahaSysEx.checksum([0x7f, 0x7f, 0x7f] as [UInt8]) == 0x03)
    }

    @Test
    func checksum_wraps() {
        let bytes = [UInt8](repeating: 0x7f, count: 300)

        #expect(YamahaSysEx.checksum(bytes) == (0 &- bytes.reduce(0, &+)) & 0x7f)
    }

    @Test
    func statusByte() {
        #expect(YamahaSysEx.statusByte(YamahaSysEx.bulkDumpKind, 1) == 0x00)
        #expect(YamahaSysEx.statusByte(YamahaSysEx.parameterChangeKind, 2) == 0x11)
        #expect(YamahaSysEx.statusByte(YamahaSysEx.dumpRequestKind, 16) == 0x2f)
    }
}
