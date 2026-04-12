// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFEventTimeTests {
}

// MARK: -

extension SMFEventTimeTests {
    @Test
    func test_beatTime() {
        let eventTime = SMFEventTime(uintValue: 960)!                   // swiftlint:disable:this force_unwrapping
        let tickRate = SMFTickRate(uintValue: 480)!                     // swiftlint:disable:this force_unwrapping

        #expect(eventTime.beatTime(tickRate) == 2.0)
    }

    @Test
    func test_init_uintValue() {
        let eventTime = SMFEventTime(uintValue: 0)

        #expect(eventTime != nil)
        #expect(eventTime?.uintValue == 0)

        let eventTime2 = SMFEventTime(uintValue: 0x7FFF_FFFF)

        #expect(eventTime2 != nil)
        #expect(eventTime2?.uintValue == 0x7FFF_FFFF)
    }

    @Test
    func test_init_uintValue_invalid() {
        #expect(SMFEventTime(uintValue: 0x8000_0000) == nil)
    }

    @Test
    func test_isValid() {
        #expect(SMFEventTime.isValid(0))
        #expect(SMFEventTime.isValid(0x7FFF_FFFF))
        #expect(!SMFEventTime.isValid(0x8000_0000))
    }

    @Test
    func test_smpteTime() {
        let eventTime = SMFEventTime(uintValue: 100)!                   // swiftlint:disable:this force_unwrapping
        let timeCode = SMPTETimeCode(frameRate: .fps25, tickRate: 4)!   // swiftlint:disable:this force_unwrapping
        let time = eventTime.smpteTime(timeCode)

        #expect(time.frameRate == .fps25)
        #expect(time.hour == 0)
        #expect(time.minute == 0)
        #expect(time.second == 1)
        #expect(time.frame == 0)
        #expect(time.fraction == 0)
    }

    @Test
    func test_zero() {
        #expect(SMFEventTime.zero.uintValue == 0)
    }
}
