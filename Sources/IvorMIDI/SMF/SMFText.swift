// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A text string stored in an SMF file, whose characters are encodable
/// as single bytes.
public struct SMFText: StringRepresentable {

    // MARK: Public Initializers

    /// Creates an `SMFText` instance with the provided string value, or
    /// `nil` if the string is not valid for SMF storage.
    ///
    /// - Parameter stringValue:    The text string.
    public init?(stringValue: String) {
        guard Self.isValid(stringValue)
        else { return nil }

        self.stringValue = stringValue
    }

    // MARK: Public Instance Properties

    /// The text string.
    public let stringValue: String
}

// MARK: - BytesValueConvertible

extension SMFText: BytesValueConvertible {

    // MARK: Public Initializers

    /// Creates an `SMFText` instance from the provided array of bytes,
    /// or `nil` if the bytes cannot be decoded as a valid text string.
    ///
    /// - Parameter bytesValue: The array of bytes, each representing a
    ///                         single character.
    public init?(bytesValue: [UInt8]) {
        let text = String(bytesValue.map { Character(Unicode.Scalar($0)) })

        self.init(stringValue: text)
    }

    // MARK: Public Instance Properties

    /// The array of bytes representing this text string, or `nil` if any
    /// character cannot be encoded as a single byte.
    public var bytesValue: [UInt8]? {
        var bytes: [UInt8] = []

        for scalar in stringValue.unicodeScalars {
            guard let byte = UInt8(exactly: scalar.value)
            else { return nil }

            bytes.append(byte)
        }

        return bytes
    }
}

// MARK: - Sendable

extension SMFText: Sendable {
}
