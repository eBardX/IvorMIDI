// © 2026 John Gary Pusey (see LICENSE.md)

// What Yamaha’s system exclusive format shares across models. Tags, parameter
// groups, and parameter numbers belong to each model.
internal enum YamahaSysEx {
}

// MARK: -

extension YamahaSysEx {

    // MARK: Internal Type Properties

    internal static let bulkDumpKind: UInt8 = 0x00
    internal static let dumpRequestKind: UInt8 = 0x20
    internal static let parameterChangeKind: UInt8 = 0x10

    // MARK: Internal Type Methods

    // Returns the data that the size and checksum of a bulk dump cover, or nil
    // if the payload is too short, or its size or checksum doesn’t match.
    internal static func bulkDumpData(_ payload: [UInt8]) -> ArraySlice<UInt8>? {
        guard payload.count >= 5
        else { return nil }

        let data = payload[4..<(payload.count - 1)]
        let size = (Int(payload[2]) << 7) | Int(payload[3])

        guard size == data.count,
              payload[payload.count - 1] == checksum(data)
        else { return nil }

        return data
    }

    // Returns “0n ff <size high> <size low> data cc”. The size and checksum
    // cover the data only, not the format byte or the size bytes.
    internal static func bulkDumpPayload(channel: MIDIChannel,
                                         format: UInt8,
                                         data: [UInt8]) -> [UInt8] {
        [statusByte(bulkDumpKind, channel),
         format,
         UInt8(truncatingIfNeeded: data.count >> 7),
         UInt8(truncatingIfNeeded: data.count & 0x7f)]
            + data
            + [checksum(data)]
    }

    internal static func checksum(_ bytes: some Sequence<UInt8>) -> UInt8 {
        (0 &- bytes.reduce(0, &+)) & 0x7f
    }

    internal static func statusByte(_ kind: UInt8,
                                    _ channel: MIDIChannel) -> UInt8 {
        kind | UInt8(truncatingIfNeeded: channel.uintValue - 1)
    }
}
