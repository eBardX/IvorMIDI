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
