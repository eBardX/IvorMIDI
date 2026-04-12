// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFTickRateTests {
}

// MARK: -

extension SMFTickRateTests {
    @Test
    func test_bytesValue() {
        #expect(SMFTickRate(uintValue: 0)?.bytesValue == [0x00, 0x00])
        #expect(SMFTickRate(uintValue: 480)?.bytesValue == [0x01, 0xE0])
        #expect(SMFTickRate(uintValue: 32_767)?.bytesValue == [0x7F, 0xFF])
    }

    @Test
    func test_init_bytesValue() {
        let tickRate = SMFTickRate(bytesValue: [0x01, 0xE0])

        #expect(tickRate != nil)
        #expect(tickRate?.uintValue == 480)
    }

    @Test
    func test_init_bytesValue_invalidCount() {
        #expect(SMFTickRate(bytesValue: []) == nil)
        #expect(SMFTickRate(bytesValue: [0x00]) == nil)
        #expect(SMFTickRate(bytesValue: [0x00, 0x00, 0x00]) == nil)
    }

    @Test
    func test_init_uintValue() {
        #expect(SMFTickRate(uintValue: 0) != nil)
        #expect(SMFTickRate(uintValue: 480) != nil)
        #expect(SMFTickRate(uintValue: 32_767) != nil)
    }

    @Test
    func test_init_uintValue_invalid() {
        #expect(SMFTickRate(uintValue: 32_768) == nil)
    }

    @Test
    func test_isValid() {
        #expect(SMFTickRate.isValid(0))
        #expect(SMFTickRate.isValid(480))
        #expect(SMFTickRate.isValid(32_767))
        #expect(!SMFTickRate.isValid(32_768))
    }

    @Test
    func test_roundTrip() {
        let tickRate = SMFTickRate(uintValue: 960)
        let bytes = tickRate?.bytesValue

        #expect(bytes != nil)

        let roundTripped = bytes.flatMap { SMFTickRate(bytesValue: $0) }

        #expect(roundTripped?.uintValue == 960)
    }
}
