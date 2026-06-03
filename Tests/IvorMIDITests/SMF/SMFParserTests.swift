// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing

struct SMFParserTests {
}

// MARK: -

extension SMFParserTests {
    @Test
    func parse_format0() throws {
        let data = makeFormat0Data()
        let parser = SMFParser()
        let sequence = try parser.parse(data)

        #expect(sequence.format == .format0)
        #expect(sequence.tracks.count == 1)
    }

    @Test
    func parse_highTrackCount_notRejected() {
        var bytes: [UInt8] = []

        bytes += [0x4d, 0x54, 0x68, 0x64]
        bytes += [0x00, 0x00, 0x00, 0x06]
        bytes += [0x00, 0x01]
        bytes += [0x80, 0x00]
        bytes += [0x01, 0xe0]

        do {
            _ = try SMFParser().parse(Data(bytes))

            Issue.record("Expected error to be thrown")
        } catch SMFParseError.notEnoughTrackChunks {
            // track count 0x8000 accepted; parse fails only because no track chunks follow
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func parse_invalid_emptyData() {
        let parser = SMFParser()

        #expect(throws: (any Error).self) {
            try parser.parse(Data())
        }
    }

    @Test
    func parse_invalid_missingHeader() {
        let data = Data([0x4d,
                         0x54,
                         0x72,
                         0x6b,
                         0x00,
                         0x00,
                         0x00,
                         0x04,
                         0x00,
                         0xff,
                         0x2f,
                         0x00])
        let parser = SMFParser()

        #expect(throws: (any Error).self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_unknownMetaEvent() throws {
        var bytes: [UInt8] = []

        bytes += [0x4d, 0x54, 0x68, 0x64]
        bytes += [0x00, 0x00, 0x00, 0x06]
        bytes += [0x00, 0x00]
        bytes += [0x00, 0x01]
        bytes += [0x01, 0xe0]

        bytes += [0x4d, 0x54, 0x72, 0x6b]
        bytes += [0x00, 0x00, 0x00, 0x0a]
        bytes += [0x00, 0xff, 0x42, 0x02, 0xde, 0xad]
        bytes += [0x00, 0xff, 0x2f, 0x00]

        let sequence = try SMFParser().parse(Data(bytes))

        #expect(sequence.tracks.count == 1)
        #expect(sequence.tracks[0].events.count == 2)

        if case let .meta(_, .unknown(typeByte, data)) = sequence.tracks[0].events[0] {
            #expect(typeByte == 0x42)
            #expect(data == [0xde, 0xad])
        } else {
            Issue.record("Expected unknown meta-event")
        }
    }

    @Test
    func parse_roundTrip() throws {
        let data = makeFormat0Data()
        let parser = SMFParser()
        let sequence = try parser.parse(data)
        let formatted = try SMFFormatter().format(sequence)
        let reparsed = try parser.parse(formatted)

        #expect(reparsed.format == .format0)
        #expect(reparsed.tracks.count == 1)
    }
}
