// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing
import XestiTools

struct SMFParseErrorTests {
}

// MARK: -

extension SMFParseErrorTests {
    @Test
    func category() {
        let error = SMFParseError.dataExhaustedPrematurely

        #expect(error.category?.description == "IvorMIDI")
    }

    @Test
    func message_dataExhaustedPrematurely() {
        let error = SMFParseError.dataExhaustedPrematurely

        #expect(error.message == "Data exhausted prematurely")
    }

    @Test
    func message_emptyTrack() {
        let error = SMFParseError.emptyTrack

        #expect(!error.message.isEmpty)
    }

    @Test
    func message_invalidChannelMessage() {
        let error = SMFParseError.invalidChannelMessage(0x90, [0x3c])

        #expect(error.message.contains("90"))
    }

    @Test
    func message_invalidChunkType() {
        let error = SMFParseError.invalidChunkType("XXXX")

        #expect(error.message.contains("XXXX"))
    }

    @Test
    func message_missingHeaderChunk() {
        let error = SMFParseError.missingHeaderChunk

        #expect(!error.message.isEmpty)
    }

    @Test
    func message_notEnoughTrackChunks() {
        let error = SMFParseError.notEnoughTrackChunks

        #expect(!error.message.isEmpty)
    }

    @Test
    func message_tooManyHeaderChunks() {
        let error = SMFParseError.tooManyHeaderChunks

        #expect(!error.message.isEmpty)
    }

    @Test
    func message_tooManyTrackChunks() {
        let error = SMFParseError.tooManyTrackChunks

        #expect(!error.message.isEmpty)
    }

    @Test
    func message_unexpectedDataByte() {
        let error = SMFParseError.unexpectedDataByte(0x3c)

        #expect(error.message.contains("3C"))
    }

    @Test
    func message_unknownChannelMessageStatus() {
        let error = SMFParseError.unknownChannelMessageStatus(0xf0)

        #expect(error.message.contains("F0"))
    }

    @Test
    func message_unknownEventStatus() {
        let error = SMFParseError.unknownEventStatus(0xf5)

        #expect(error.message.contains("F5"))
    }
}
