// © 2026 John Gary Pusey (see LICENSE.md)

extension SMFParser {

    // MARK: Public Nested Types

    /// Controls how strictly the parser enforces Standard MIDI Files conformance.
    public enum Strictness {
        /// Tolerates common real-world deviations and collects
        /// ``SMFDiagnostic`` values describing what was recovered.
        case lenient

        /// Requires strict conformance to the Standard MIDI Files specification; any
        /// deviation throws an error. This is the default.
        case strict
    }
}

// MARK: - Equatable

extension SMFParser.Strictness: Equatable {
}

// MARK: - Sendable

extension SMFParser.Strictness: Sendable {
}
