// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorMIDI
import Testing
import XestiTools

struct MIDIDeviceMemberTests {
}

// MARK: -

extension MIDIDeviceMemberTests {
    @Test
    func codable() throws {
        let original: MIDIDeviceMember = 15_489
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIDeviceMember.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("16384".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDIDeviceMember.self,
                                     from: data)
        }
    }

    @Test(arguments: [0, 8, 16_383] as [UInt])
    func init_uintValue_inRange(value: UInt) {
        #expect(MIDIDeviceMember(uintValue: value)?.uintValue == value)
    }

    @Test
    func init_uintValue_outOfRange() {
        #expect(MIDIDeviceMember(uintValue: 16_384) == nil)
    }

    @Test
    func init_value() {
        #expect(MIDIDeviceMember(value: 12_345).uintValue == 12_345)
    }

    @Test
    func isValid() {
        #expect(MIDIDeviceMember.isValid(0))
        #expect(MIDIDeviceMember.isValid(16_383))
        #expect(!MIDIDeviceMember.isValid(16_384))
    }

    @Test
    func value() {
        let member: MIDIDeviceMember = 12_345

        #expect(member.value == 12_345)
    }
}
