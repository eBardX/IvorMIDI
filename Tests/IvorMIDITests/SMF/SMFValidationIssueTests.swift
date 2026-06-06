// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFValidationIssueTests {
}

// MARK: -

extension SMFValidationIssueTests {
    @Test
    func message_eventAfterEndOfTrack() {
        let issue = SMFValidationIssue.eventAfterEndOfTrack(trackIndex: 3)

        #expect(issue.message.contains("3"))
    }

    @Test
    func message_missingEndOfTrack() {
        let issue = SMFValidationIssue.missingEndOfTrack(trackIndex: 4)

        #expect(issue.message.contains("4"))
    }

    @Test
    func message_sequenceNumberNotAtTimeZero() {
        let issue = SMFValidationIssue.sequenceNumberNotAtTimeZero(trackIndex: 5)

        #expect(issue.message.contains("5"))
    }

    @Test
    func message_tempoInNonTempoTrack() {
        let issue = SMFValidationIssue.tempoInNonTempoTrack(trackIndex: 6)

        #expect(issue.message.contains("6"))
    }

    @Test
    func message_timeSignatureInNonTempoTrack() {
        let issue = SMFValidationIssue.timeSignatureInNonTempoTrack(trackIndex: 7)

        #expect(issue.message.contains("7"))
    }

    @Test
    func severity() {
        #expect(SMFValidationIssue.eventAfterEndOfTrack(trackIndex: 0).severity == .error)
        #expect(SMFValidationIssue.missingEndOfTrack(trackIndex: 0).severity == .error)
        #expect(SMFValidationIssue.sequenceNumberNotAtTimeZero(trackIndex: 0).severity == .warning)
        #expect(SMFValidationIssue.tempoInNonTempoTrack(trackIndex: 0).severity == .warning)
        #expect(SMFValidationIssue.timeSignatureInNonTempoTrack(trackIndex: 0).severity == .warning)
    }

    @Test
    func trackIndex() {
        #expect(SMFValidationIssue.eventAfterEndOfTrack(trackIndex: 1).trackIndex == 1)
        #expect(SMFValidationIssue.missingEndOfTrack(trackIndex: 2).trackIndex == 2)
        #expect(SMFValidationIssue.sequenceNumberNotAtTimeZero(trackIndex: 3).trackIndex == 3)
        #expect(SMFValidationIssue.tempoInNonTempoTrack(trackIndex: 4).trackIndex == 4)
        #expect(SMFValidationIssue.timeSignatureInNonTempoTrack(trackIndex: 5).trackIndex == 5)
    }
}
