// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

/// A parser that decodes raw binary data into an ``SMFSequence``.
public struct SMFParser {

    // MARK: Public Initializers

    /// Creates a new `SMFParser` instance.
    public init() {
    }
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
        var reader = Reader(data: data)

        return try reader.readSequence()
    }
}

// MARK: - Sendable

extension SMFParser: Sendable {
}
