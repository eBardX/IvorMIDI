// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An SMF sequence consisting of a format identifier, a time division,
/// and one or more tracks.
public struct SMFSequence {

    // MARK: Public Initializers

    /// Creates a new `SMFSequence` instance with the provided format,
    /// time division, and tracks.
    ///
    /// - Parameter format:     The SMF format identifier.
    /// - Parameter division:   The time division.
    /// - Parameter tracks:     The tracks in the sequence. Format 0 requires
    ///                         exactly one track; formats 1 and 2 require
    ///                         between 1 and 65,535 tracks (inclusive).
    ///
    /// - Precondition: The number of tracks must be compatible with `format`.
    public init(format: SMFFormat,
                division: SMFDivision,
                tracks: [SMFTrack]) {
        precondition((format == .format0 && tracks.count == 1)
                     || (format != .format0 && (1...0xffff).contains(tracks.count)),
                     "Track count \(tracks.count) is incompatible with SMF format \(format)")

        self.division = division
        self.format = format
        self.tracks = tracks
    }

    // MARK: Public Instance Properties

    /// The time division of this sequence.
    public let division: SMFDivision

    /// The SMF format identifier of this sequence.
    public let format: SMFFormat

    /// The tracks in this sequence.
    public let tracks: [SMFTrack]
}

// MARK: -

extension SMFSequence {

    // MARK: Public Instance Methods

    /// Validates this sequence against the Standard MIDI Files specification
    /// and returns any issues found.
    ///
    /// Error-severity issues indicate violations that will prevent correct
    /// playback or cause ``SMFFormatter`` to throw. Warning-severity issues
    /// indicate deviations from “should” rules in the specification that may
    /// cause interoperability problems.
    ///
    /// - Returns:  An array of ``SMFValidationIssue`` values. An empty array
    ///             means the sequence is fully conformant.
    public func validate() -> [SMFValidationIssue] {
        var issues: [SMFValidationIssue] = []

        for (idx, track) in tracks.enumerated() {
            if let eotIndex = track.events.firstIndex(where: { $0.isEndOfTrack }) {
                if eotIndex < track.events.count - 1 {
                    issues.append(.eventAfterEndOfTrack(trackIndex: idx))
                }
            } else {
                issues.append(.missingEndOfTrack(trackIndex: idx))
            }

            for event in track.events {
                guard case let .meta(eventTime, message) = event
                else { continue }

                if case .sequenceNumber = message,
                   eventTime != .zero {
                    issues.append(.sequenceNumberNotAtTimeZero(trackIndex: idx))
                }

                if format == .format1,
                   idx > 0 {
                    if case .tempo = message {
                        issues.append(.tempoInNonTempoTrack(trackIndex: idx))
                    }

                    if case .timeSignature = message {
                        issues.append(.timeSignatureInNonTempoTrack(trackIndex: idx))
                    }
                }
            }
        }

        return issues
    }
}

// MARK: - Equatable

extension SMFSequence: Equatable {
}

// MARK: - Hashable

extension SMFSequence: Hashable {
}

// MARK: - Sendable

extension SMFSequence: Sendable {
}
