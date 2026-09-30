// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorMIDI
import Testing
import XestiTools

struct MIDIChannelTests {
}

// MARK: -

extension MIDIChannelTests {
    @Test
    func bytesValue() {
        let channel = MIDIChannel(uintValue: 1)

        #expect(channel?.bytesValue == [0x00])

        let channel16 = MIDIChannel(uintValue: 16)

        #expect(channel16?.bytesValue == [0x0f])
    }

    @Test
    func codable() throws {
        let original: MIDIChannel = 3
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MIDIChannel.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func codable_invalidValueThrows() {
        let data = Data("17".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(MIDIChannel.self,
                                     from: data)
        }
    }

    @Test
    func comparable() {
        let low: MIDIChannel = 3
        let high: MIDIChannel = 10

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func description() {
        let value: MIDIChannel = 3

        #expect(value.description == "3")
    }

    @Test
    func equality() {
        let value1: MIDIChannel = 3
        let value2: MIDIChannel = 3
        let value3: MIDIChannel = 10

        #expect(value1 == value2)
        #expect(value1 != value3)
    }

    @Test
    func hashable() {
        let set: Set<MIDIChannel> = [3, 3, 10]

        #expect(set.count == 2)
    }

    @Test
    func init_bytesValue() {
        let channel = MIDIChannel(bytesValue: [0x00])

        #expect(channel != nil)
        #expect(channel?.uintValue == 1)

        let channel16 = MIDIChannel(bytesValue: [0x0f])

        #expect(channel16 != nil)
        #expect(channel16?.uintValue == 16)
    }

    @Test
    func init_bytesValue_invalidCount() {
        #expect(MIDIChannel(bytesValue: []) == nil)
        #expect(MIDIChannel(bytesValue: [0x00, 0x01]) == nil)
    }

    @Test
    func init_integerLiteral() {
        let value: MIDIChannel = 3

        #expect(value.uintValue == 3)
    }

    @Test
    func init_uintValue() {
        let channel = MIDIChannel(uintValue: 1)

        #expect(channel != nil)
        #expect(channel?.uintValue == 1)

        let channel16 = MIDIChannel(uintValue: 16)

        #expect(channel16 != nil)
        #expect(channel16?.uintValue == 16)
    }

    @Test
    func init_uintValue_invalid() {
        #expect(MIDIChannel(uintValue: 0) == nil)
        #expect(MIDIChannel(uintValue: 17) == nil)
    }

    @Test
    func isValid() {
        #expect(!MIDIChannel.isValid(0))
        #expect(MIDIChannel.isValid(1))
        #expect(MIDIChannel.isValid(8))
        #expect(MIDIChannel.isValid(16))
        #expect(!MIDIChannel.isValid(17))
    }
}
