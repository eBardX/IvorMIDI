// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing

struct MIDIManufacturerIDTests {
}

// MARK: -

extension MIDIManufacturerIDTests {
    @Test
    func codable() throws {
        let original = try #require(MIDIManufacturerID(bytes: [0x00, 0x21, 0x09]))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIManufacturerID.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test(arguments: ["[]", "[126]", "[0, 33]", "[1, 2, 3]", "[0, 128, 9]"])
    func codable_invalidBytesThrow(json: String) {
        let data = Data(json.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDIManufacturerID.self,
                                     from: data)
        }
    }

    @Test
    func hashable() {
        let set: Set<MIDIManufacturerID> = [.yamaha,
                                            .yamaha,
                                            .korg]

        #expect(set.count == 2)
    }

    @Test(arguments: [0x01, 0x40, 0x7c] as [UInt8])
    func init_oneByte(byte: UInt8) {
        #expect(MIDIManufacturerID(bytes: [byte])?.bytes == [byte])
    }

    @Test(arguments: [0x00, 0x7d, 0x7e, 0x7f, 0x80, 0xf7] as [UInt8])
    func init_oneByte_invalid(byte: UInt8) {
        #expect(MIDIManufacturerID(bytes: [byte]) == nil)
    }

    @Test
    func init_threeBytes() {
        #expect(MIDIManufacturerID(bytes: [0x00, 0x21, 0x09])?.bytes == [0x00, 0x21, 0x09])
    }

    @Test
    func init_threeBytes_dataByteAbove7F() {
        #expect(MIDIManufacturerID(bytes: [0x00, 0x80, 0x09]) == nil)
        #expect(MIDIManufacturerID(bytes: [0x00, 0x21, 0xf7]) == nil)
    }

    @Test
    func init_threeBytes_notStartingWithZero() {
        #expect(MIDIManufacturerID(bytes: [0x43, 0x21, 0x09]) == nil)
    }

    @Test
    func init_wrongLength() {
        #expect(MIDIManufacturerID(bytes: []) == nil)
        #expect(MIDIManufacturerID(bytes: [0x00, 0x21]) == nil)
        #expect(MIDIManufacturerID(bytes: [0x00, 0x21, 0x09, 0x01]) == nil)
    }
}
