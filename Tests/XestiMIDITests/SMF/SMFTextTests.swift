// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFTextTests {
}

// MARK: -

extension SMFTextTests {
    @Test
    func test_bytesValue() {
        let text = SMFText(stringValue: "ABC")

        #expect(text?.bytesValue == [0x41, 0x42, 0x43])
    }

    @Test
    func test_init_bytesValue() {
        let text = SMFText(bytesValue: [0x48, 0x69])

        #expect(text != nil)
        #expect(text?.stringValue == "Hi")
    }

    @Test
    func test_init_bytesValue_empty() {
        #expect(SMFText(bytesValue: []) == nil)
    }

    @Test
    func test_init_stringValue() {
        let text = SMFText(stringValue: "Hello")

        #expect(text != nil)
        #expect(text?.stringValue == "Hello")
    }

    @Test
    func test_init_stringValue_empty() {
        #expect(SMFText(stringValue: "") == nil)
    }

    @Test
    func test_roundTrip() {
        let text = SMFText(stringValue: "Test 123")
        let bytes = text?.bytesValue

        #expect(bytes != nil)

        let roundTripped = bytes.flatMap { SMFText(bytesValue: $0) }

        #expect(roundTripped?.stringValue == "Test 123")
    }
}
