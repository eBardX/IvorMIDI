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
    /// - Parameter tracks:     The tracks in the sequence.
    public init(format: SMFFormat,
                division: SMFDivision,
                tracks: [SMFTrack]) {
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

// MARK: - Sendable

extension SMFSequence: Sendable {
}
