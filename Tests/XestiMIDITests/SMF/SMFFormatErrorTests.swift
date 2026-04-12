// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct SMFFormatErrorTests {
}

// MARK: -

extension SMFFormatErrorTests {
    @Test
    func test_category() {
        let error = SMFFormatError.badByte(0)

        #expect(error.category?.description == "IvorMIDI")
    }

    @Test
    func test_message_badByte() {
        let error = SMFFormatError.badByte(256)

        #expect(error.message.contains("256"))
    }

    @Test
    func test_message_badChunkLength() {
        let error = SMFFormatError.badChunkLength(999)

        #expect(error.message.contains("999"))
    }

    @Test
    func test_message_badVarlen() {
        let error = SMFFormatError.badVarlen(999)

        #expect(error.message.contains("999"))
    }

    @Test
    func test_message_badWord() {
        let error = SMFFormatError.badWord(999)

        #expect(error.message.contains("999"))
    }
}
