// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

/// An encoder that converts an ``SMFSequence`` to raw binary data.
public struct SMFFormatter {

    // MARK: Public Initializers

    /// Creates a new `SMFFormatter` instance.
    public init() {
    }
}

// MARK: -

extension SMFFormatter {

    // MARK: Public Instance Methods

    /// Returns the raw binary data encoding of the provided SMF sequence.
    ///
    /// - Parameter sequence:   The SMF sequence to encode.
    ///
    /// - Returns:  The encoded data.
    ///
    /// - Throws:   ``SMFFormatError`` if the sequence cannot be encoded.
    public func format(_ sequence: SMFSequence) throws -> Data {
        var writer = Writer(sequence: sequence)

        return try writer.writeSequence()
    }
}

// MARK: - Sendable

extension SMFFormatter: Sendable {
}
