// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMPTETimeCodeTests {
}

// MARK: -

extension SMPTETimeCodeTests {
    @Test
    func bytesValue() {
        let tc = SMPTETimeCode(frameRate: .fps24, tickRate: 4)

        #expect(tc?.bytesValue == [0xe8, 0x04])
    }

    @Test
    func bytesValue_fps25() {
        let tc = SMPTETimeCode(frameRate: .fps25, tickRate: 40)

        #expect(tc?.bytesValue == [0xe7, 40])
    }

    @Test
    func bytesValue_fps2997() {
        let tc = SMPTETimeCode(frameRate: .fps2997, tickRate: 4)

        #expect(tc?.bytesValue == [0xe3, 0x04])
    }

    @Test
    func bytesValue_fps30() {
        let tc = SMPTETimeCode(frameRate: .fps30, tickRate: 4)

        #expect(tc?.bytesValue == [0xe2, 0x04])
    }

    @Test
    func equality() {
        let tc1 = SMPTETimeCode(frameRate: .fps24, tickRate: 4)!    // swiftlint:disable:this force_unwrapping
        let tc2 = SMPTETimeCode(frameRate: .fps24, tickRate: 4)!    // swiftlint:disable:this force_unwrapping

        #expect(tc1 == tc2)
    }

    @Test
    func hashable() {
        let tc1 = SMPTETimeCode(frameRate: .fps24, tickRate: 4)!    // swiftlint:disable:this force_unwrapping
        let tc2 = SMPTETimeCode(frameRate: .fps24, tickRate: 4)!    // swiftlint:disable:this force_unwrapping
        let set: Set<SMPTETimeCode> = [tc1, tc2]

        #expect(set.count == 1)
    }

    @Test
    func inequality_differentTickRate() {
        let tc1 = SMPTETimeCode(frameRate: .fps24, tickRate: 4)!    // swiftlint:disable:this force_unwrapping
        let tc2 = SMPTETimeCode(frameRate: .fps24, tickRate: 5)!    // swiftlint:disable:this force_unwrapping

        #expect(tc1 != tc2)
    }

    @Test
    func init_bytesValue() {
        let tc = SMPTETimeCode(bytesValue: [0xe8, 0x04])

        #expect(tc != nil)
        #expect(tc?.frameRate == .fps24)
        #expect(tc?.tickRate == 4)
    }

    @Test
    func init_bytesValue_fps25() {
        let tc = SMPTETimeCode(bytesValue: [0xe7, 40])

        #expect(tc != nil)
        #expect(tc?.frameRate == .fps25)
        #expect(tc?.tickRate == 40)
    }

    @Test
    func init_bytesValue_fps2997() {
        let tc = SMPTETimeCode(bytesValue: [0xe3, 0x04])

        #expect(tc != nil)
        #expect(tc?.frameRate == .fps2997)
    }

    @Test
    func init_bytesValue_fps30() {
        let tc = SMPTETimeCode(bytesValue: [0xe2, 0x04])

        #expect(tc != nil)
        #expect(tc?.frameRate == .fps30)
    }

    @Test
    func init_bytesValue_invalidCount() {
        #expect(SMPTETimeCode(bytesValue: []) == nil)
        #expect(SMPTETimeCode(bytesValue: [0xe8]) == nil)
        #expect(SMPTETimeCode(bytesValue: [0xe8, 0x04, 0x00]) == nil)
    }

    @Test
    func init_bytesValue_invalidFrameRate() {
        #expect(SMPTETimeCode(bytesValue: [0x00, 0x04]) == nil)
        #expect(SMPTETimeCode(bytesValue: [0xe0, 0x04]) == nil)
    }

    @Test
    func init_invalid_tickRate() {
        #expect(SMPTETimeCode(frameRate: .fps24, tickRate: 256) == nil)
    }

    @Test
    func init_validValues() {
        let tc = SMPTETimeCode(frameRate: .fps24, tickRate: 4)

        #expect(tc != nil)
        #expect(tc?.frameRate == .fps24)
        #expect(tc?.tickRate == 4)
    }

    @Test
    func init_validValues_tickRateBoundaries() {
        let tc0 = SMPTETimeCode(frameRate: .fps24, tickRate: 0)

        #expect(tc0?.tickRate == 0)

        let tc255 = SMPTETimeCode(frameRate: .fps24, tickRate: 255)

        #expect(tc255?.tickRate == 255)
    }

    @Test
    func roundTrip() {
        let tc = SMPTETimeCode(frameRate: .fps25, tickRate: 40)
        let bytes = tc?.bytesValue

        #expect(bytes != nil)

        let roundTripped = bytes.flatMap { SMPTETimeCode(bytesValue: $0) }

        #expect(roundTripped?.frameRate == .fps25)
        #expect(roundTripped?.tickRate == 40)
    }
}
