// © 2026 John Gary Pusey (see LICENSE.md)

/// A diagnostic message produced by ``SMFParser`` when parsing in lenient
/// mode.
public enum SMFDiagnostic {

    /// A chunk’s declared length exceeded the available data and was clamped
    /// to the remaining bytes.
    case chunkLengthClamped(declared: UInt, available: UInt)

    /// A track ended without a terminal End-of-Track meta-event.
    case missingEndOfTrack(trackIndex: Int)

    /// A stray system real-time byte was skipped in the event stream.
    case strayRealTimeByteSkipped

    /// The number of track chunks found differed from the count declared in
    /// the header.
    case trackCountMismatch(declared: UInt, actual: UInt)

    /// A format-0 file contained more than one track chunk and was
    /// reinterpreted as format 1.
    case trackFormatCoerced(from: SMFFormat, to: SMFFormat)
}

// MARK: -

extension SMFDiagnostic {

    // MARK: Public Instance Properties

    /// A human-readable description of this diagnostic.
    public var message: String {
        switch self {
        case let .chunkLengthClamped(declared, available):
            "Chunk length \(declared) exceeds available data; clamped to \(available)"

        case let .missingEndOfTrack(trackIndex):
            "Track \(trackIndex) has no terminal End-of-Track event"

        case .strayRealTimeByteSkipped:
            "Stray system real-time byte skipped"

        case let .trackCountMismatch(declared, actual):
            "Header declared \(declared) track(s); found \(actual)"

        case let .trackFormatCoerced(from, to):
            "Format-\(from.uintValue) file contained multiple tracks; reinterpreted as format \(to.uintValue)"
        }
    }
}

// MARK: - Equatable

extension SMFDiagnostic: Equatable {
}

// MARK: - Sendable

extension SMFDiagnostic: Sendable {
}
