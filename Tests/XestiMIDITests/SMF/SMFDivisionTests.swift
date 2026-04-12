// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFDivisionTests {
}

// MARK: -

extension SMFDivisionTests {
    @Test
    func test_bytesValue_metrical() {
        let tickRate = SMFTickRate(uintValue: 480)!                     // swiftlint:disable:this force_unwrapping
        let division = SMFDivision.metrical(tickRate)

        #expect(division.bytesValue == [0x01, 0xE0])
    }

    @Test
    func test_bytesValue_timeCode() {
        let timeCode = SMPTETimeCode(frameRate: .fps24, tickRate: 4)!   // swiftlint:disable:this force_unwrapping
        let division = SMFDivision.timeCode(timeCode)

        #expect(division.bytesValue == [0xE8, 0x04])
    }

    @Test
    func test_init_bytesValue_invalidCount() {
        #expect(SMFDivision(bytesValue: []) == nil)
        #expect(SMFDivision(bytesValue: [0x00]) == nil)
        #expect(SMFDivision(bytesValue: [0x00, 0x00, 0x00]) == nil)
    }

    @Test
    func test_init_bytesValue_metrical() {
        let division = SMFDivision(bytesValue: [0x01, 0xE0])

        #expect(division != nil)

        if case let .metrical(tickRate) = division {
            #expect(tickRate.uintValue == 480)
        } else {
            Issue.record("Expected metrical division")
        }
    }

    @Test
    func test_init_bytesValue_timeCode() {
        let division = SMFDivision(bytesValue: [0xE8, 0x04])

        #expect(division != nil)

        if case let .timeCode(timeCode) = division {
            #expect(timeCode.frameRate == .fps24)
            #expect(timeCode.tickRate == 4)
        } else {
            Issue.record("Expected timeCode division")
        }
    }
}
