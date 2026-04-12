// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFEventTests {
}

// MARK: -

extension SMFEventTests {
    @Test
    func test_eventTime_meta() {
        let eventTime = SMFEventTime(uintValue: 100)!               // swiftlint:disable:this force_unwrapping
        let event = SMFEvent.meta(eventTime, .endOfTrack)

        #expect(event.eventTime.uintValue == 100)
    }

    @Test
    func test_eventTime_midi() {
        let eventTime = SMFEventTime(uintValue: 200)!               // swiftlint:disable:this force_unwrapping
        let msg = MIDIChannelMessage(statusByte: 0x90,
                                     dataBytes: [0x3C, 0x64])!      // swiftlint:disable:this force_unwrapping
        let event = SMFEvent.midi(eventTime, msg)

        #expect(event.eventTime.uintValue == 200)
    }

    @Test
    func test_eventTime_sysEx() {
        let eventTime = SMFEventTime(uintValue: 300)!               // swiftlint:disable:this force_unwrapping
        let msg = SMFSysExMessage(statusByte: 0xF0,
                                  dataBytes: [0x7E, 0xF7])!         // swiftlint:disable:this force_unwrapping
        let event = SMFEvent.sysEx(eventTime, msg)

        #expect(event.eventTime.uintValue == 300)
    }
}
