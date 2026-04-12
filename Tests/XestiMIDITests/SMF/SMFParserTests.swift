// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing

struct SMFParserTests {
}

// MARK: -

extension SMFParserTests {
    @Test
    func test_parse_format0() throws {
        let data = _makeFormat0Data()
        let parser = SMFParser()
        let sequence = try parser.parse(data)

        #expect(sequence.format == .format0)
        #expect(sequence.tracks.count == 1)
    }

    @Test
    func test_parse_invalid_emptyData() {
        let parser = SMFParser()

        #expect(throws: (any Error).self) {
            try parser.parse(Data())
        }
    }

    @Test
    func test_parse_invalid_missingHeader() {
        let data = Data([0x4D, 0x54, 0x72, 0x6B,
                         0x00, 0x00, 0x00, 0x04,
                         0x00, 0xFF, 0x2F, 0x00])
        let parser = SMFParser()

        #expect(throws: (any Error).self) {
            try parser.parse(data)
        }
    }

    @Test
    func test_parse_roundTrip() throws {
        let data = _makeFormat0Data()
        let parser = SMFParser()
        let sequence = try parser.parse(data)
        let formatted = try SMFFormatter().format(sequence)
        let reparsed = try parser.parse(formatted)

        #expect(reparsed.format == .format0)
        #expect(reparsed.tracks.count == 1)
    }

    private func _makeFormat0Data() -> Data {
        var bytes: [UInt8] = []

        bytes += [0x4D, 0x54, 0x68, 0x64]
        bytes += [0x00, 0x00, 0x00, 0x06]
        bytes += [0x00, 0x00]
        bytes += [0x00, 0x01]
        bytes += [0x01, 0xE0]

        bytes += [0x4D, 0x54, 0x72, 0x6B]
        bytes += [0x00, 0x00, 0x00, 0x14]
        bytes += [0x00, 0xFF, 0x51, 0x03, 0x07, 0xA1, 0x20]
        bytes += [0x00, 0x90, 0x3C, 0x64]
        bytes += [0x83, 0x60, 0x80, 0x3C, 0x40]
        bytes += [0x00, 0xFF, 0x2F, 0x00]

        return Data(bytes)
    }
}
