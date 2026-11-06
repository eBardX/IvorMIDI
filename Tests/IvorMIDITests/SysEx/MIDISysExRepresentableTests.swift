// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct MIDISysExRepresentableTests {
}

// MARK: -

extension MIDISysExRepresentableTests {
    @Test
    func init_message() {
        let message = StubSysExMessage(MIDISystemMessage.systemExclusive([0x7d, 0x01, 0xf7]))

        #expect(message?.payload == [0x01])
    }

    @Test
    func init_message_invalidFraming() {
        #expect(StubSysExMessage(MIDISystemMessage.systemExclusive([0x7d, 0x01])) == nil)
    }

    @Test
    func init_message_notSystemExclusive() {
        #expect(StubSysExMessage(MIDISystemMessage.timingClock) == nil)
    }

    @Test
    func init_message_wrongOwner() {
        #expect(StubSysExMessage(MIDISystemMessage.systemExclusive([0x43, 0x01, 0xf7])) == nil)
    }

    @Test
    func systemMessage() {
        let message = StubSysExMessage(payload: [0x01])

        #expect(message.systemMessage == .systemExclusive([0x7d, 0x01, 0xf7]))
    }

    @Test
    func systemMessage_dataByteAbove7F() {
        let message = StubSysExMessage(payload: [0x80])

        #expect(message.envelope != nil)
        #expect(message.systemMessage == nil)
    }

    @Test
    func systemMessage_notEncodable() {
        let message = StubSysExMessage(payload: [])

        #expect(message.systemMessage == nil)
    }

    @Test
    func systemMessage_roundTrip() throws {
        let original = StubSysExMessage(payload: [0x01, 0x02])
        let message = try #require(original.systemMessage)

        #expect(StubSysExMessage(message) == original)
    }
}
