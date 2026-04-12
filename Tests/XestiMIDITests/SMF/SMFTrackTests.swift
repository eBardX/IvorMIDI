// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFTrackTests {
}

// MARK: -

extension SMFTrackTests {
    @Test
    func test_events() {
        let eventTime = SMFEventTime(uintValue: 0)!                 // swiftlint:disable:this force_unwrapping
        let events: [SMFEvent] = [.meta(eventTime, .endOfTrack)]
        let track = SMFTrack(events: events)

        #expect(track.events.count == 1)
        #expect(track.events[0].eventTime.uintValue == 0)
    }

    @Test
    func test_events_multiple() {
        let t0 = SMFEventTime(uintValue: 0)!                        // swiftlint:disable:this force_unwrapping
        let t480 = SMFEventTime(uintValue: 480)!                    // swiftlint:disable:this force_unwrapping
        let noteOn = MIDIChannelMessage(statusByte: 0x90,
                                        dataBytes: [0x3C, 0x64])!   // swiftlint:disable:this force_unwrapping
        let events: [SMFEvent] = [.midi(t0, noteOn),
                                  .meta(t480, .endOfTrack)]
        let track = SMFTrack(events: events)

        #expect(track.events.count == 2)
    }
}
