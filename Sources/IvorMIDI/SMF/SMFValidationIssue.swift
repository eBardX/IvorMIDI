// © 2026 John Gary Pusey (see LICENSE.md)

/// An issue found when validating an ``SMFSequence`` against the Standard
/// MIDI Files specification.
public enum SMFValidationIssue {

    /// One or more events follow the End-of-Track meta-event in this track.
    case eventAfterEndOfTrack(trackIndex: Int)

    /// This track has no terminal End-of-Track meta-event.
    case missingEndOfTrack(trackIndex: Int)

    /// A sequence-number meta-event in this track does not appear at time
    /// zero.
    case sequenceNumberNotAtTimeZero(trackIndex: Int)

    /// A tempo meta-event appears in a track other than the first track of a
    /// format-1 file.
    case tempoInNonTempoTrack(trackIndex: Int)

    /// A time-signature meta-event appears in a track other than the first
    /// track of a format-1 file.
    case timeSignatureInNonTempoTrack(trackIndex: Int)
}

// MARK: -

extension SMFValidationIssue {

    // MARK: Public Instance Properties

    /// A human-readable description of this issue.
    public var message: String {
        switch self {
        case let .eventAfterEndOfTrack(trackIndex):
            "Track \(trackIndex) has events after the End-of-Track meta-event"

        case let .missingEndOfTrack(trackIndex):
            "Track \(trackIndex) is missing a terminal End-of-Track meta-event"

        case let .sequenceNumberNotAtTimeZero(trackIndex):
            "Track \(trackIndex) has a sequence-number event that does not appear at time zero"

        case let .tempoInNonTempoTrack(trackIndex):
            "Track \(trackIndex) contains a tempo event; tempo events should appear only in the first track of a format-1 file"

        case let .timeSignatureInNonTempoTrack(trackIndex):
            "Track \(trackIndex) contains a time-signature event; time-signature events should appear only in the first track of a format-1 file"
        }
    }

    /// The severity of this issue.
    public var severity: Severity {
        switch self {
        case .eventAfterEndOfTrack,
             .missingEndOfTrack:
            .error

        case .sequenceNumberNotAtTimeZero,
             .tempoInNonTempoTrack,
             .timeSignatureInNonTempoTrack:
            .warning
        }
    }

    /// The zero-based index of the track that contains this issue.
    public var trackIndex: Int {
        switch self {
        case let .eventAfterEndOfTrack(trackIndex),
             let .missingEndOfTrack(trackIndex),
             let .sequenceNumberNotAtTimeZero(trackIndex),
             let .tempoInNonTempoTrack(trackIndex),
             let .timeSignatureInNonTempoTrack(trackIndex):
            trackIndex
        }
    }
}

// MARK: - Equatable

extension SMFValidationIssue: Equatable {
}

// MARK: - Hashable

extension SMFValidationIssue: Hashable {
}

// MARK: - Sendable

extension SMFValidationIssue: Sendable {
}
