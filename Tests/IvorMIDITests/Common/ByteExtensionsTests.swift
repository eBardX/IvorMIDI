// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct ByteExtensionsTests {
}

// MARK: -

extension ByteExtensionsTests {
    @Test
    func hex_multipleBytes() {
        let bytes: [UInt8] = [0x00, 0x0a, 0xff]

        #expect(bytes.hex == "00 0A FF")
    }

    @Test
    func hex_noBytes() {
        let bytes: [UInt8] = []

        #expect(bytes.hex.isEmpty)
    }

    @Test
    func hex_singleByte() {
        let bytes: [UInt8] = [0x42]

        #expect(bytes.hex == "42")
    }

    @Test
    func hex_singleDigitValue() {
        #expect(UInt8(0x00).hex == "00")
        #expect(UInt8(0x01).hex == "01")
        #expect(UInt8(0x0f).hex == "0F")
    }

    @Test
    func hex_twoDigitValue() {
        #expect(UInt8(0x10).hex == "10")
        #expect(UInt8(0x7f).hex == "7F")
        #expect(UInt8(0xff).hex == "FF")
    }
}
