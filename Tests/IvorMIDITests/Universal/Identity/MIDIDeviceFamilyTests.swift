// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorMIDI
import Testing
import XestiTools

struct MIDIDeviceFamilyTests {
}

// MARK: -

extension MIDIDeviceFamilyTests {
    @Test
    func codable() throws {
        let original: MIDIDeviceFamily = 15_489
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIDeviceFamily.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("16384".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDIDeviceFamily.self,
                                     from: data)
        }
    }

    @Test(arguments: [0, 8, 16_383] as [UInt])
    func init_uintValue_inRange(value: UInt) {
        #expect(MIDIDeviceFamily(uintValue: value)?.uintValue == value)
    }

    @Test
    func init_uintValue_outOfRange() {
        #expect(MIDIDeviceFamily(uintValue: 16_384) == nil)
    }

    @Test
    func init_value() {
        #expect(MIDIDeviceFamily(value: 12_345).uintValue == 12_345)
    }

    @Test
    func isValid() {
        #expect(MIDIDeviceFamily.isValid(0))
        #expect(MIDIDeviceFamily.isValid(16_383))
        #expect(!MIDIDeviceFamily.isValid(16_384))
    }

    @Test
    func value() {
        let family: MIDIDeviceFamily = 12_345

        #expect(family.value == 12_345)
    }
}
