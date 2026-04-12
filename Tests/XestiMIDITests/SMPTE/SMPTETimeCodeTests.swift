// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMPTETimeCodeTests {
}

// MARK: -

extension SMPTETimeCodeTests {
    @Test
    func test_bytesValue() {
        let tc = SMPTETimeCode(frameRate: .fps24, tickRate: 4)

        #expect(tc?.bytesValue == [0xE8, 0x04])
    }

    @Test
    func test_bytesValue_fps25() {
        let tc = SMPTETimeCode(frameRate: .fps25, tickRate: 40)

        #expect(tc?.bytesValue == [0xE7, 40])
    }

    @Test
    func test_bytesValue_fps2997() {
        let tc = SMPTETimeCode(frameRate: .fps2997, tickRate: 4)

        #expect(tc?.bytesValue == [0xE3, 0x04])
    }

    @Test
    func test_bytesValue_fps30() {
        let tc = SMPTETimeCode(frameRate: .fps30, tickRate: 4)

        #expect(tc?.bytesValue == [0xE2, 0x04])
    }

    @Test
    func test_init() {
        let tc = SMPTETimeCode(frameRate: .fps24, tickRate: 4)

        #expect(tc != nil)
        #expect(tc?.frameRate == .fps24)
        #expect(tc?.tickRate == 4)
    }

    @Test
    func test_init_bytesValue() {
        let tc = SMPTETimeCode(bytesValue: [0xE8, 0x04])

        #expect(tc != nil)
        #expect(tc?.frameRate == .fps24)
        #expect(tc?.tickRate == 4)
    }

    @Test
    func test_init_bytesValue_fps25() {
        let tc = SMPTETimeCode(bytesValue: [0xE7, 40])

        #expect(tc != nil)
        #expect(tc?.frameRate == .fps25)
        #expect(tc?.tickRate == 40)
    }

    @Test
    func test_init_bytesValue_fps2997() {
        let tc = SMPTETimeCode(bytesValue: [0xE3, 0x04])

        #expect(tc != nil)
        #expect(tc?.frameRate == .fps2997)
    }

    @Test
    func test_init_bytesValue_fps30() {
        let tc = SMPTETimeCode(bytesValue: [0xE2, 0x04])

        #expect(tc != nil)
        #expect(tc?.frameRate == .fps30)
    }

    @Test
    func test_init_bytesValue_invalidCount() {
        #expect(SMPTETimeCode(bytesValue: []) == nil)
        #expect(SMPTETimeCode(bytesValue: [0xE8]) == nil)
        #expect(SMPTETimeCode(bytesValue: [0xE8, 0x04, 0x00]) == nil)
    }

    @Test
    func test_init_bytesValue_invalidFrameRate() {
        #expect(SMPTETimeCode(bytesValue: [0x00, 0x04]) == nil)
        #expect(SMPTETimeCode(bytesValue: [0xE0, 0x04]) == nil)
    }

    @Test
    func test_init_invalid_tickRate() {
        #expect(SMPTETimeCode(frameRate: .fps24, tickRate: 256) == nil)
    }

    @Test
    func test_roundTrip() {
        let tc = SMPTETimeCode(frameRate: .fps25, tickRate: 40)
        let bytes = tc?.bytesValue

        #expect(bytes != nil)

        let roundTripped = bytes.flatMap { SMPTETimeCode(bytesValue: $0) }

        #expect(roundTripped?.frameRate == .fps25)
        #expect(roundTripped?.tickRate == 40)
    }
}
