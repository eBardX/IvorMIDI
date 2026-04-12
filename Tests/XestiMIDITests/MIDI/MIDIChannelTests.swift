// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDIChannelTests {
}

// MARK: -

extension MIDIChannelTests {
    @Test
    func test_bytesValue() {
        let channel = MIDIChannel(uintValue: 1)

        #expect(channel?.bytesValue == [0x00])

        let channel16 = MIDIChannel(uintValue: 16)

        #expect(channel16?.bytesValue == [0x0F])
    }

    @Test
    func test_init_bytesValue() {
        let channel = MIDIChannel(bytesValue: [0x00])

        #expect(channel != nil)
        #expect(channel?.uintValue == 1)

        let channel16 = MIDIChannel(bytesValue: [0x0F])

        #expect(channel16 != nil)
        #expect(channel16?.uintValue == 16)
    }

    @Test
    func test_init_bytesValue_invalidCount() {
        #expect(MIDIChannel(bytesValue: []) == nil)
        #expect(MIDIChannel(bytesValue: [0x00, 0x01]) == nil)
    }

    @Test
    func test_init_uintValue() {
        let channel = MIDIChannel(uintValue: 1)

        #expect(channel != nil)
        #expect(channel?.uintValue == 1)

        let channel16 = MIDIChannel(uintValue: 16)

        #expect(channel16 != nil)
        #expect(channel16?.uintValue == 16)
    }

    @Test
    func test_init_uintValue_invalid() {
        #expect(MIDIChannel(uintValue: 0) == nil)
        #expect(MIDIChannel(uintValue: 17) == nil)
    }

    @Test
    func test_isValid() {
        #expect(!MIDIChannel.isValid(0))
        #expect(MIDIChannel.isValid(1))
        #expect(MIDIChannel.isValid(8))
        #expect(MIDIChannel.isValid(16))
        #expect(!MIDIChannel.isValid(17))
    }
}
