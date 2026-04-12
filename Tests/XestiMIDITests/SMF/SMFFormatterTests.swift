// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing

struct SMFFormatterTests {
}

// MARK: -

extension SMFFormatterTests {
    @Test
    func test_format_format0() throws {
        let t0 = SMFEventTime(uintValue: 0)!                        // swiftlint:disable:this force_unwrapping
        let tempo = SMFTempo(uintValue: 500_000)!                   // swiftlint:disable:this force_unwrapping
        let noteOn = MIDIChannelMessage(statusByte: 0x90,
                                        dataBytes: [0x3C, 0x64])!   // swiftlint:disable:this force_unwrapping
        let t480 = SMFEventTime(uintValue: 480)!                    // swiftlint:disable:this force_unwrapping
        let noteOff = MIDIChannelMessage(statusByte: 0x80,
                                         dataBytes: [0x3C, 0x40])!  // swiftlint:disable:this force_unwrapping
        let track = SMFTrack(events: [.meta(t0, .tempo(tempo)),
                                      .midi(t0, noteOn),
                                      .midi(t480, noteOff),
                                      .meta(t480, .endOfTrack)])
        let tickRate = SMFTickRate(uintValue: 480)!                 // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format0,
                                   division: .metrical(tickRate),
                                   tracks: [track])
        let data = try SMFFormatter().format(sequence)

        #expect(!data.isEmpty)
        #expect(data[0] == 0x4D)
        #expect(data[1] == 0x54)
        #expect(data[2] == 0x68)
        #expect(data[3] == 0x64)
    }

    @Test
    func test_format_format1_multiTrack() throws {
        let t0 = SMFEventTime(uintValue: 0)!                        // swiftlint:disable:this force_unwrapping
        let t480 = SMFEventTime(uintValue: 480)!                    // swiftlint:disable:this force_unwrapping
        let tempo = SMFTempo(uintValue: 500_000)!                   // swiftlint:disable:this force_unwrapping
        let noteOn = MIDIChannelMessage(statusByte: 0x90,
                                        dataBytes: [0x3C, 0x64])!   // swiftlint:disable:this force_unwrapping
        let noteOff = MIDIChannelMessage(statusByte: 0x80,
                                         dataBytes: [0x3C, 0x40])!  // swiftlint:disable:this force_unwrapping
        let track0 = SMFTrack(events: [.meta(t0, .tempo(tempo)),
                                       .meta(t480, .endOfTrack)])
        let track1 = SMFTrack(events: [.midi(t0, noteOn),
                                       .midi(t480, noteOff),
                                       .meta(t480, .endOfTrack)])
        let tickRate = SMFTickRate(uintValue: 480)!                 // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format1,
                                   division: .metrical(tickRate),
                                   tracks: [track0, track1])
        let data = try SMFFormatter().format(sequence)
        let reparsed = try SMFParser().parse(data)

        #expect(reparsed.format == .format1)
        #expect(reparsed.tracks.count == 2)
        #expect(reparsed.tracks[0].events.count == 2)
        #expect(reparsed.tracks[1].events.count == 3)
    }

    @Test
    func test_format_headerContainsFormat() throws {
        let t0 = SMFEventTime(uintValue: 0)!                        // swiftlint:disable:this force_unwrapping
        let track = SMFTrack(events: [.meta(t0, .endOfTrack)])
        let tickRate = SMFTickRate(uintValue: 480)!                 // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format0,
                                   division: .metrical(tickRate),
                                   tracks: [track])
        let data = try SMFFormatter().format(sequence)

        #expect(data[8] == 0x00)
        #expect(data[9] == 0x00)
    }

    @Test
    func test_format_roundTrip() throws {
        let t0 = SMFEventTime(uintValue: 0)!                        // swiftlint:disable:this force_unwrapping
        let noteOn = MIDIChannelMessage(statusByte: 0x90,
                                        dataBytes: [0x3C, 0x64])!   // swiftlint:disable:this force_unwrapping
        let t480 = SMFEventTime(uintValue: 480)!                    // swiftlint:disable:this force_unwrapping
        let noteOff = MIDIChannelMessage(statusByte: 0x80,
                                         dataBytes: [0x3C, 0x40])!  // swiftlint:disable:this force_unwrapping
        let track = SMFTrack(events: [.midi(t0, noteOn),
                                      .midi(t480, noteOff),
                                      .meta(t480, .endOfTrack)])
        let tickRate = SMFTickRate(uintValue: 480)!                 // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format0,
                                   division: .metrical(tickRate),
                                   tracks: [track])
        let data = try SMFFormatter().format(sequence)
        let reparsed = try SMFParser().parse(data)

        #expect(reparsed.format == .format0)
        #expect(reparsed.tracks.count == 1)
        #expect(reparsed.tracks[0].events.count == 3)
    }
}
