// © 2026 John Gary Pusey (see LICENSE.md)

extension SMFValidationIssue {

    // MARK: Public Nested Types

    /// The severity of a validation issue.
    public enum Severity {

        /// A violation that will prevent correct playback or cause the
        /// formatter to throw.
        case error

        /// A deviation from a “should” rule in the specification that may
        /// cause interoperability problems.
        case warning
    }
}

// MARK: - Equatable

extension SMFValidationIssue.Severity: Equatable {
}

// MARK: - Sendable

extension SMFValidationIssue.Severity: Sendable {
}
