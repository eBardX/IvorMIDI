// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFSequenceTests {
}

// MARK: -

extension SMFSequenceTests {
    @Test
    func test_init() {
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
    func test_init_format1() {
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
}
