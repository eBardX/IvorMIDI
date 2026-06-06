// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

/// A parser that decodes raw binary data into an ``SMFSequence``.
public struct SMFParser {

    // MARK: Public Initializers

    /// Creates a new `SMFParser` instance with the specified strictness.
    ///
    /// - Parameter strictness: Controls how the parser handles deviations
    ///                         from the SMF specification. Defaults to
    ///                         ``Strictness/strict``, which preserves the
    ///                         existing throwing behavior.
    public init(strictness: Strictness = .strict) {
        self.strictness = strictness
    }

    // MARK: Private Instance Properties

    private let strictness: Strictness
}

// MARK: -

extension SMFParser {

    // MARK: Public Instance Methods

    /// Parses the provided data and returns the decoded SMF sequence.
    ///
    /// - Parameter data:   The raw binary data to parse.
    ///
    /// - Returns:  The decoded ``SMFSequence``.
    ///
    /// - Throws:   ``SMFParseError`` if the data cannot be parsed as a valid
    ///             SMF sequence.
    public func parse(_ data: Data) throws -> SMFSequence {
        var reader = Reader(data: data,
                            strictness: strictness)

        let (sequence, _) = try reader.readSequence()

        return sequence
    }

    /// Parses the provided data and returns the decoded SMF sequence along
    /// with any diagnostic messages produced during lenient recovery.
    ///
    /// In ``Strictness/strict`` mode, the returned diagnostics array is always
    /// empty.
    ///
    /// - Parameter data:   The raw binary data to parse.
    ///
    /// - Returns:  A tuple containing the decoded ``SMFSequence`` and an
    ///             array of ``SMFDiagnostic`` values describing any
    ///             recoveries performed.
    ///
    /// - Throws:   ``SMFParseError`` if the data cannot be parsed as a valid
    ///             SMF sequence.
    public func parseWithDiagnostics(_ data: Data) throws -> (SMFSequence, [SMFDiagnostic]) {
        var reader = Reader(data: data,
                            strictness: strictness)

        return try reader.readSequence()
    }
}

// MARK: - Sendable

extension SMFParser: Sendable {
}
