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
    func parse_format0Example_roundTrip() throws {
        let data = try loadFixture("format0_example", extension: "mid")
        let sequence = try SMFParser().parse(data)
        let reformatted = try SMFFormatter().format(sequence)

        #expect(reformatted == data)
    }

    @Test
    func parse_format0Example_structure() throws {
        let data = try loadFixture("format0_example", extension: "mid")
        let sequence = try SMFParser().parse(data)

        #expect(sequence.format == .format0)
        #expect(sequence.division.bytesValue == [0x00, 0x60])
        #expect(sequence.tracks.count == 1)

        let events = sequence.tracks[0].events

        #expect(events.count == 14)

        if case let .meta(t, .timeSignature) = events[0] {
            #expect(t == .zero)
        } else {
            Issue.record("Expected timeSignature at events[0]")
        }

        if case let .meta(t, .tempo(bpm)) = events[1] {
            #expect(t == .zero)
            #expect(bpm.uintValue == 500_000)
        } else {
            Issue.record("Expected tempo at events[1]")
        }

        #expect(events.last?.isEndOfTrack == true)

        if case let .meta(t, .endOfTrack) = events[13] {
            #expect(t.uintValue == 384)
        } else {
            Issue.record("Expected endOfTrack at events[13]")
        }
    }

    @Test
    func parse_format0ManyTracks_lenient_coercedToFormat1() throws {
        var bytes = makeHeaderBytes(format: 0x0000, ntrks: 0x0002, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])
        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])

        let (sequence, diagnostics) = try SMFParser(strictness: .lenient).parseWithDiagnostics(Data(bytes))

        #expect(sequence.format == .format1)
        #expect(diagnostics.contains(.trackFormatCoerced(from: .format0, to: .format1)))
    }

    @Test
    func parse_format0ManyTracks_strict_throws() {
        var bytes = makeHeaderBytes(format: 0x0000, ntrks: 0x0002, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])
        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])

        #expect(throws: (any Error).self) {
            try SMFParser(strictness: .strict).parse(Data(bytes))
        }
    }

    @Test
    func parse_format1Example_roundTrip() throws {
        let data = try loadFixture("format1_example", extension: "mid")
        let sequence = try SMFParser().parse(data)
        let reformatted = try SMFFormatter().format(sequence)

        #expect(reformatted == data)
    }

    @Test
    func parse_format1Example_structure() throws {
        let data = try loadFixture("format1_example", extension: "mid")
        let sequence = try SMFParser().parse(data)

        #expect(sequence.format == .format1)
        #expect(sequence.division.bytesValue == [0x00, 0x60])
        #expect(sequence.tracks.count == 4)

        #expect(sequence.tracks[0].events.count == 3)   // time-sig, tempo, EOT
        #expect(sequence.tracks[1].events.count == 4)   // prog, note-on, note-off, EOT
        #expect(sequence.tracks[2].events.count == 4)   // prog, note-on, note-off, EOT
        #expect(sequence.tracks[3].events.count == 6)   // prog, 2×note-on, 2×note-off, EOT

        for track in sequence.tracks {
            #expect(track.events.last?.isEndOfTrack == true)
        }

        if case let .meta(t, .endOfTrack) = sequence.tracks[0].events[2] {
            #expect(t.uintValue == 384)
        } else {
            Issue.record("Expected endOfTrack at track0 events[2]")
        }
    }

    @Test
    func parse_format2_accepted() throws {
        var bytes = makeHeaderBytes(format: 0x0002, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])

        let sequence = try SMFParser().parse(Data(bytes))

        #expect(sequence.format == .format2)
        #expect(sequence.tracks.count == 1)
    }

    @Test
    func parse_highTrackCount_lenient() throws {
        var bytes: [UInt8] = []

        bytes += [0x4d, 0x54, 0x68, 0x64]
        bytes += [0x00, 0x00, 0x00, 0x06]
        bytes += [0x00, 0x01]
        bytes += [0x00, 0x02]   // ntrks declares 2
        bytes += [0x01, 0xe0]

        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])  // only 1 track provided

        let parser = SMFParser(strictness: .lenient)
        let (sequence, diagnostics) = try parser.parseWithDiagnostics(Data(bytes))

        #expect(sequence.tracks.count == 1)
        #expect(diagnostics.contains(.trackCountMismatch(declared: 2, actual: 1)))
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
        } catch SMFParseError.invalidTrackCount(0, _) {
            // track count 0x8000 accepted; parse fails because no MTrk chunks follow
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
        let data = Data([0x4d, 0x54, 0x72, 0x6b, 0x00, 0x00, 0x00, 0x04, 0x00, 0xff, 0x2f, 0x00])
        let parser = SMFParser()

        #expect(throws: (any Error).self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_keySignature_roundTrip() throws {
        // C major: FF 59 02 00 00
        let content: [UInt8] = [0x00, 0xff, 0x59, 0x02, 0x00, 0x00, 0x00, 0xff, 0x2f, 0x00]
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes(content)

        let sequence = try SMFParser().parse(Data(bytes))

        if case let .meta(_, .keySignature(ks)) = sequence.tracks[0].events[0] {
            #expect(ks == .cMajor)
        } else {
            Issue.record("Expected keySignature event")
        }

        let reformatted = try SMFFormatter().format(sequence)

        #expect(reformatted == Data(bytes))
    }

    @Test
    func parse_missingEndOfTrack_lenient_emitsDiagnostic() throws {
        var bytes = makeHeaderBytes(format: 0x0000, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0x90, 0x3c, 0x40])

        let (sequence, diagnostics) = try SMFParser(strictness: .lenient).parseWithDiagnostics(Data(bytes))

        #expect(sequence.tracks[0].events.count == 1)
        #expect(diagnostics.contains(.missingEndOfTrack(trackIndex: 0)))
    }

    @Test
    func parse_missingEndOfTrack_strict_succeeds() throws {
        var bytes = makeHeaderBytes(format: 0x0000, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0x90, 0x3c, 0x40])

        let sequence = try SMFParser(strictness: .strict).parse(Data(bytes))

        #expect(sequence.tracks[0].events.count == 1)
        #expect(sequence.tracks[0].events[0].isEndOfTrack == false)
    }

    @Test
    func parse_multiPacketSysEx_roundTrip() throws {
        // F0 packet without terminal F7, followed by F7 continuation
        let content: [UInt8] = [0x00,
                                0xf0,
                                0x02,
                                0x41,
                                0x10,
                                0x00,
                                0xf7,
                                0x02,
                                0x02,
                                0xf7,
                                0x00,
                                0xff,
                                0x2f,
                                0x00]
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes(content)

        let sequence = try SMFParser().parse(Data(bytes))

        #expect(sequence.tracks[0].events.count == 3)

        if case let .sysEx(_, .systemExclusive(data)) = sequence.tracks[0].events[0] {
            #expect(data == [0x41, 0x10])
        } else {
            Issue.record("Expected systemExclusive at events[0]")
        }

        if case let .sysEx(_, .escape(data)) = sequence.tracks[0].events[1] {
            #expect(data == [0x02, 0xf7])
        } else {
            Issue.record("Expected escape at events[1]")
        }

        let reformatted = try SMFFormatter().format(sequence)

        #expect(reformatted == Data(bytes))
    }

    @Test
    func parse_postEOTPadding_strict_succeeds() throws {
        let content: [UInt8] = [0x00, 0xff, 0x2f, 0x00, 0x00, 0x00, 0x00]
        var bytes = makeHeaderBytes(format: 0x0000, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes(content)

        let sequence = try SMFParser(strictness: .strict).parse(Data(bytes))

        #expect(sequence.tracks[0].events.count == 1)
        #expect(sequence.tracks[0].events[0].isEndOfTrack == true)
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

    @Test
    func parse_runningStatusWithMultiByteDelta_roundTrip() throws {
        // delta=200 in VLQ: 200 = 128+72 → 0x81 0x48
        let content: [UInt8] = [0x00,
                                0x90,
                                0x3c,
                                0x64,
                                0x81,
                                0x48,
                                0x3e,
                                0x64,
                                0x00,
                                0xff,
                                0x2f,
                                0x00]
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes(content)

        let sequence = try SMFParser().parse(Data(bytes))

        #expect(sequence.tracks[0].events.count == 3)

        if case let .midi(t, _) = sequence.tracks[0].events[1] {
            #expect(t.uintValue == 200)
        } else {
            Issue.record("Expected MIDI event at events[1]")
        }

        let reformatted = try SMFFormatter().format(sequence)

        #expect(reformatted == Data(bytes))
    }

    @Test
    func parse_smpteOffset_roundTrip() throws {
        // FF 54 05: fps24 (bits 00), hour=1 → byte0 = 0x01; min=sec=frame=frac=0
        let content: [UInt8] = [0x00,
                                0xff,
                                0x54,
                                0x05,
                                0x01,
                                0x00,
                                0x00,
                                0x00,
                                0x00,
                                0x00,
                                0xff,
                                0x2f,
                                0x00]
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes(content)

        let sequence = try SMFParser().parse(Data(bytes))

        if case let .meta(_, .smpteOffset(offset)) = sequence.tracks[0].events[0] {
            #expect(offset.frameRate == .fps24)
            #expect(offset.hour == 1)
            #expect(offset.minute == 0)
            #expect(offset.second == 0)
            #expect(offset.frame == 0)
            #expect(offset.fraction == 0)
        } else {
            Issue.record("Expected smpteOffset meta event")
        }

        let reformatted = try SMFFormatter().format(sequence)

        #expect(reformatted == Data(bytes))
    }

    @Test
    func parse_smpteTimeDivision_roundTrip() throws {
        // SMPTE fps25, 40 ticks/frame → division bytes [E7, 28]
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0001, division: 0xe728)

        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])

        let sequence = try SMFParser().parse(Data(bytes))

        guard case let .timeCode(tc) = sequence.division else {
            Issue.record("Expected timeCode division")
            return
        }

        #expect(tc.frameRate == .fps25)
        #expect(tc.tickRate == 40)

        let reformatted = try SMFFormatter().format(sequence)

        #expect(reformatted == Data(bytes))
    }

    @Test
    func parse_strayRealTimeBytes_lenient_skipped() throws {
        var bytes = makeHeaderBytes(format: 0x0000, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0xf8, 0x90, 0x3c, 0x40, 0x00, 0xff, 0x2f, 0x00])

        let (sequence, diagnostics) = try SMFParser(strictness: .lenient).parseWithDiagnostics(Data(bytes))

        #expect(sequence.tracks[0].events.count == 2)
        #expect(diagnostics.contains(.strayRealTimeByteSkipped))
    }

    @Test
    func parse_strayRealTimeBytes_strict_throws() {
        var bytes = makeHeaderBytes(format: 0x0000, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0xf8, 0x90, 0x3c, 0x40, 0x00, 0xff, 0x2f, 0x00])

        #expect(throws: (any Error).self) {
            try SMFParser(strictness: .strict).parse(Data(bytes))
        }
    }

    @Test
    func parse_sysExEscapeF7_roundTrip() throws {
        let content: [UInt8] = [0x00, 0xf7, 0x02, 0x42, 0xf7, 0x00, 0xff, 0x2f, 0x00]
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes(content)

        let sequence = try SMFParser().parse(Data(bytes))

        if case let .sysEx(_, .escape(data)) = sequence.tracks[0].events[0] {
            #expect(data == [0x42, 0xf7])
        } else {
            Issue.record("Expected escape sysex event")
        }

        let reformatted = try SMFFormatter().format(sequence)

        #expect(reformatted == Data(bytes))
    }

    @Test
    func parse_sysExF0_roundTrip() throws {
        let content: [UInt8] = [0x00, 0xf0, 0x03, 0x41, 0x10, 0xf7, 0x00, 0xff, 0x2f, 0x00]
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes(content)

        let sequence = try SMFParser().parse(Data(bytes))

        if case let .sysEx(_, .systemExclusive(data)) = sequence.tracks[0].events[0] {
            #expect(data == [0x41, 0x10, 0xf7])
        } else {
            Issue.record("Expected systemExclusive event")
        }

        let reformatted = try SMFFormatter().format(sequence)

        #expect(reformatted == Data(bytes))
    }

    @Test
    func parse_truncatedTrack_lenient_emitsDiagnostic() throws {
        var bytes = makeHeaderBytes(format: 0x0000, ntrks: 0x0001, division: 0x01e0)

        bytes += [0x4d, 0x54, 0x72, 0x6b, 0x00, 0x00, 0x00, 0x0a]
        bytes += [0x00, 0xff, 0x2f, 0x00]

        let (sequence, diagnostics) = try SMFParser(strictness: .lenient).parseWithDiagnostics(Data(bytes))

        #expect(sequence.tracks.count == 1)
        #expect(diagnostics.contains {
            if case .chunkLengthClamped = $0 {
                return true
            }

            return false
        })
    }

    @Test
    func parse_truncatedTrack_strict_throws() {
        var bytes = makeHeaderBytes(format: 0x0000, ntrks: 0x0001, division: 0x01e0)

        bytes += [0x4d, 0x54, 0x72, 0x6b, 0x00, 0x00, 0x00, 0x0a]
        bytes += [0x00, 0xff, 0x2f, 0x00]

        #expect(throws: (any Error).self) {
            try SMFParser(strictness: .strict).parse(Data(bytes))
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
    func parse_wrongNtrksHigh_lenient_succeeds() throws {
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0002, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])

        let (sequence, diagnostics) = try SMFParser(strictness: .lenient).parseWithDiagnostics(Data(bytes))

        #expect(sequence.tracks.count == 1)
        #expect(diagnostics.contains(.trackCountMismatch(declared: 2, actual: 1)))
    }

    @Test
    func parse_wrongNtrksHigh_strict_throws() {
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0002, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])

        #expect(throws: (any Error).self) {
            try SMFParser(strictness: .strict).parse(Data(bytes))
        }
    }

    @Test
    func parse_wrongNtrksLow_lenient_succeeds() throws {
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])
        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])

        let (sequence, diagnostics) = try SMFParser(strictness: .lenient).parseWithDiagnostics(Data(bytes))

        #expect(sequence.tracks.count == 2)
        #expect(diagnostics.contains(.trackCountMismatch(declared: 1, actual: 2)))
    }

    @Test
    func parse_wrongNtrksLow_strict_throws() {
        var bytes = makeHeaderBytes(format: 0x0001, ntrks: 0x0001, division: 0x01e0)

        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])
        bytes += makeTrackBytes([0x00, 0xff, 0x2f, 0x00])

        #expect(throws: (any Error).self) {
            try SMFParser(strictness: .strict).parse(Data(bytes))
        }
    }

    @Test
    func parse_zeroLengthMTrk_throws() {
        var bytes = makeHeaderBytes(format: 0x0000, ntrks: 0x0001, division: 0x01e0)

        bytes += [0x4d, 0x54, 0x72, 0x6b, 0x00, 0x00, 0x00, 0x00]

        #expect(throws: (any Error).self) {
            try SMFParser(strictness: .strict).parse(Data(bytes))
        }
    }
}
