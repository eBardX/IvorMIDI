// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFDiagnosticTests {
}

// MARK: -

extension SMFDiagnosticTests {
    @Test
    func message_chunkLengthClamped() {
        let diagnostic = SMFDiagnostic.chunkLengthClamped(declared: 1_000, available: 42)

        #expect(diagnostic.message.contains("1000"))
        #expect(diagnostic.message.contains("42"))
    }

    @Test
    func message_missingEndOfTrack() {
        let diagnostic = SMFDiagnostic.missingEndOfTrack(trackIndex: 7)

        #expect(diagnostic.message.contains("7"))
    }

    @Test
    func message_strayRealTimeByteSkipped() {
        #expect(!SMFDiagnostic.strayRealTimeByteSkipped.message.isEmpty)
    }

    @Test
    func message_trackCountMismatch() {
        let diagnostic = SMFDiagnostic.trackCountMismatch(declared: 5, actual: 3)

        #expect(diagnostic.message.contains("5"))
        #expect(diagnostic.message.contains("3"))
    }

    @Test
    func message_trackFormatCoerced() {
        let diagnostic = SMFDiagnostic.trackFormatCoerced(from: .format0, to: .format1)

        #expect(diagnostic.message.contains("0"))
        #expect(diagnostic.message.contains("1"))
    }
}
