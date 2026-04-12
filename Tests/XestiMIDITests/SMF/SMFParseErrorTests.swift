// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct SMFParseErrorTests {
}

// MARK: -

extension SMFParseErrorTests {
    @Test
    func test_category() {
        let error = SMFParseError.dataExhaustedPrematurely

        #expect(error.category?.description == "IvorMIDI")
    }

    @Test
    func test_message_dataExhaustedPrematurely() {
        let error = SMFParseError.dataExhaustedPrematurely

        #expect(error.message == "Data exhausted prematurely")
    }

    @Test
    func test_message_emptyTrack() {
        let error = SMFParseError.emptyTrack

        #expect(!error.message.isEmpty)
    }

    @Test
    func test_message_invalidChannelMessage() {
        let error = SMFParseError.invalidChannelMessage(0x90, [0x3C])

        #expect(error.message.contains("90"))
    }

    @Test
    func test_message_invalidChunkType() {
        let error = SMFParseError.invalidChunkType("XXXX")

        #expect(error.message.contains("XXXX"))
    }

    @Test
    func test_message_missingHeaderChunk() {
        let error = SMFParseError.missingHeaderChunk

        #expect(!error.message.isEmpty)
    }

    @Test
    func test_message_notEnoughTrackChunks() {
        let error = SMFParseError.notEnoughTrackChunks

        #expect(!error.message.isEmpty)
    }

    @Test
    func test_message_tooManyHeaderChunks() {
        let error = SMFParseError.tooManyHeaderChunks

        #expect(!error.message.isEmpty)
    }

    @Test
    func test_message_tooManyTrackChunks() {
        let error = SMFParseError.tooManyTrackChunks

        #expect(!error.message.isEmpty)
    }

    @Test
    func test_message_unexpectedDataByte() {
        let error = SMFParseError.unexpectedDataByte(0x3C)

        #expect(error.message.contains("3C"))
    }

    @Test
    func test_message_unknownChannelMessageStatus() {
        let error = SMFParseError.unknownChannelMessageStatus(0xF0)

        #expect(error.message.contains("F0"))
    }

    @Test
    func test_message_unknownEventStatus() {
        let error = SMFParseError.unknownEventStatus(0xF5)

        #expect(error.message.contains("F5"))
    }
}
