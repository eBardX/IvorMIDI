// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorMIDI
import Testing

struct SMFValidationIssueSeverityTests {
}

// MARK: -

extension SMFValidationIssueSeverityTests {
    @Test
    func equality() {
        #expect(SMFValidationIssue.Severity.error == .error)
        #expect(SMFValidationIssue.Severity.warning == .warning)
    }

    @Test
    func inequality() {
        #expect(SMFValidationIssue.Severity.error != .warning)
    }
}
