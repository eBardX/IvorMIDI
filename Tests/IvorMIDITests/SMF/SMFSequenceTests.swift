// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing

struct SMFSequenceTests {
}

// MARK: -

extension SMFSequenceTests {
    @Test
    func init_format0() {
        let eventTime = SMFEventTime(uintValue: 0)!                     // swiftlint:disable:this force_unwrapping
        let track = SMFTrack(events: [.meta(eventTime, .endOfTrack)])
        let tickRate = SMFTickRate(uintValue: 480)!                     // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format0,
                                   division: .metrical(tickRate),
                                   tracks: [track])

        #expect(sequence.format == .format0)
        #expect(sequence.tracks.count == 1)

        if case let .metrical(tr) = sequence.division {
            #expect(tr.uintValue == 480)
        } else {
            Issue.record("Expected metrical division")
        }
    }

    @Test
    func init_format1() {
        let eventTime = SMFEventTime(uintValue: 0)!                     // swiftlint:disable:this force_unwrapping
        let track1 = SMFTrack(events: [.meta(eventTime, .endOfTrack)])
        let track2 = SMFTrack(events: [.meta(eventTime, .endOfTrack)])
        let tickRate = SMFTickRate(uintValue: 480)!                     // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format1,
                                   division: .metrical(tickRate),
                                   tracks: [track1, track2])

        #expect(sequence.format == .format1)
        #expect(sequence.tracks.count == 2)
    }

    @Test
    func init_format1_highTrackCount() {
        let track = SMFTrack(events: [])
        let tracks = Array(repeating: track, count: 0x8000)
        let tickRate = SMFTickRate(uintValue: 480)!                     // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format1,
                                   division: .metrical(tickRate),
                                   tracks: tracks)

        #expect(sequence.tracks.count == 0x8000)
    }

    @Test
    func validate_cleanSequence_noIssues() throws {
        let sequence = try SMFParser().parse(makeFormat0Data())

        #expect(sequence.validate().isEmpty)
    }

    @Test
    func validate_eventAfterEndOfTrack() {
        let t0 = SMFEventTime(uintValue: 0)!                        // swiftlint:disable:this force_unwrapping
        let noteOn = MIDIChannelMessage(statusByte: 0x90,
                                        dataBytes: [0x3c, 0x64])!   // swiftlint:disable:this force_unwrapping
        let track = SMFTrack(events: [.meta(t0, .endOfTrack),
                                      .midi(t0, noteOn)])
        let tickRate = SMFTickRate(uintValue: 96)!                  // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format0,
                                   division: .metrical(tickRate),
                                   tracks: [track])

        let issues = sequence.validate()

        #expect(issues == [.eventAfterEndOfTrack(trackIndex: 0)])
        #expect(issues[0].severity == .error)
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_missingEndOfTrack() {
        let t0 = SMFEventTime(uintValue: 0)!                        // swiftlint:disable:this force_unwrapping
        let noteOn = MIDIChannelMessage(statusByte: 0x90,
                                        dataBytes: [0x3c, 0x64])!   // swiftlint:disable:this force_unwrapping
        let track = SMFTrack(events: [.midi(t0, noteOn)])
        let tickRate = SMFTickRate(uintValue: 96)!                  // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format0,
                                   division: .metrical(tickRate),
                                   tracks: [track])

        let issues = sequence.validate()

        #expect(issues == [.missingEndOfTrack(trackIndex: 0)])
        #expect(issues[0].severity == .error)
    }

    @Test
    func validate_sequenceNumberNotAtTimeZero() {
        let t96 = SMFEventTime(uintValue: 96)!                      // swiftlint:disable:this force_unwrapping
        let seqNum = SMFData2Value(uintValue: 1)!                   // swiftlint:disable:this force_unwrapping
        let track = SMFTrack(events: [.meta(t96, .sequenceNumber(seqNum)),
                                      .meta(t96, .endOfTrack)])
        let tickRate = SMFTickRate(uintValue: 96)!                  // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format0,
                                   division: .metrical(tickRate),
                                   tracks: [track])

        let issues = sequence.validate()

        #expect(issues.contains(.sequenceNumberNotAtTimeZero(trackIndex: 0)))
        #expect(issues.first { $0 == .sequenceNumberNotAtTimeZero(trackIndex: 0) }?.severity == .warning)
    }

    @Test
    func validate_tempoInNonTempoTrack_format1() {
        let t0 = SMFEventTime(uintValue: 0)!                        // swiftlint:disable:this force_unwrapping
        let tempo = SMFTempo(uintValue: 500_000)!                   // swiftlint:disable:this force_unwrapping
        let track0 = SMFTrack(events: [.meta(t0, .endOfTrack)])
        let track1 = SMFTrack(events: [.meta(t0, .tempo(tempo)),
                                       .meta(t0, .endOfTrack)])
        let tickRate = SMFTickRate(uintValue: 96)!                  // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format1,
                                   division: .metrical(tickRate),
                                   tracks: [track0, track1])

        let issues = sequence.validate()

        #expect(issues.contains(.tempoInNonTempoTrack(trackIndex: 1)))
        #expect(issues.first { $0 == .tempoInNonTempoTrack(trackIndex: 1) }?.severity == .warning)
    }

    @Test
    func validate_tempoInTrack0_format1_noIssue() {
        let t0 = SMFEventTime(uintValue: 0)!                        // swiftlint:disable:this force_unwrapping
        let tempo = SMFTempo(uintValue: 500_000)!                   // swiftlint:disable:this force_unwrapping
        let track0 = SMFTrack(events: [.meta(t0, .tempo(tempo)),
                                       .meta(t0, .endOfTrack)])
        let track1 = SMFTrack(events: [.meta(t0, .endOfTrack)])
        let tickRate = SMFTickRate(uintValue: 96)!                  // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format1,
                                   division: .metrical(tickRate),
                                   tracks: [track0, track1])

        let issues = sequence.validate()

        #expect(!issues.contains { $0 == .tempoInNonTempoTrack(trackIndex: 0) })
    }

    @Test
    func validate_timeSignatureInNonTempoTrack_format1() {
        let t0 = SMFEventTime(uintValue: 0)!                        // swiftlint:disable:this force_unwrapping
        let timeSig = SMFTimeSignature(numerator: 4,
                                       denominator: 2,
                                       clockRate: 24,
                                       beatRate: 8)!                // swiftlint:disable:this force_unwrapping
        let track0 = SMFTrack(events: [.meta(t0, .endOfTrack)])
        let track1 = SMFTrack(events: [.meta(t0, .timeSignature(timeSig)),
                                       .meta(t0, .endOfTrack)])
        let tickRate = SMFTickRate(uintValue: 96)!                  // swiftlint:disable:this force_unwrapping
        let sequence = SMFSequence(format: .format1,
                                   division: .metrical(tickRate),
                                   tracks: [track0, track1])

        let issues = sequence.validate()

        #expect(issues.contains(.timeSignatureInNonTempoTrack(trackIndex: 1)))
        #expect(issues.first { $0 == .timeSignatureInNonTempoTrack(trackIndex: 1) }?.severity == .warning)
    }
}
