// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct ByteExtensionsTests {
}

// MARK: -

extension ByteExtensionsTests {
    @Test
    func test_hex_multipleBytes() {
        let bytes: [UInt8] = [0x00, 0x0A, 0xFF]

        #expect(bytes.hex == "00 0A FF")
    }

    @Test
    func test_hex_noBytes() {
        let bytes: [UInt8] = []

        #expect(bytes.hex.isEmpty)
    }

    @Test
    func test_hex_singleByte() {
        let bytes: [UInt8] = [0x42]

        #expect(bytes.hex == "42")
    }

    @Test
    func test_hex_singleDigitValue() {
        #expect(UInt8(0x00).hex == "00")
        #expect(UInt8(0x01).hex == "01")
        #expect(UInt8(0x0F).hex == "0F")
    }

    @Test
    func test_hex_twoDigitValue() {
        #expect(UInt8(0x10).hex == "10")
        #expect(UInt8(0x7F).hex == "7F")
        #expect(UInt8(0xFF).hex == "FF")
    }
}
