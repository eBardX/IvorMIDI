// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// An error that occurs when formatting an SMF sequence to binary data.
public enum SMFFormatError {

    /// A byte value that is invalid in the formatted output.
    case badByte(UInt)

    /// A chunk length that is invalid.
    case badChunkLength(UInt)

    /// A chunk type that is not allowed in the formatted output.
    case badChunkType(SMFChunkType)

    /// A time division that is invalid.
    case badDivision(SMFDivision)

    /// An event that cannot be formatted.
    case badEvent(SMFEvent)

    /// An SMF format value that is not supported.
    case badFormat(SMFFormat)

    /// A track count that is incompatible with the SMF format.
    case badTrackCount(UInt)

    /// A value that is too large to encode as a variable-length quantity.
    case badVarlen(UInt)

    /// A word value that is invalid.
    case badWord(UInt)
}

// MARK: - EnhancedError

extension SMFFormatError: EnhancedError {
    /// Returns the error category identifying the source module.
    public var category: Category? {
        Category("IvorMIDI")
    }

    /// Returns a human-readable description of this error.
    public var message: String {
        switch self {
        case let .badByte(value):
            "Bad byte: \(value)"

        case let .badChunkLength(value):
            "Bad chunk length: \(value)"

        case let .badChunkType(value):
            "Bad chunk type: '\(value)'"

        case let .badDivision(division):
            "Bad division: \(division)"

        case let .badEvent(event):
            "Bad event: \(event)"

        case let .badFormat(format):
            "Bad format: \(format)"

        case let .badTrackCount(value):
            "Bad track count: \(value)"

        case let .badVarlen(value):
            "Bad varlen: \(value)"

        case let .badWord(value):
            "Bad word: \(value)"
        }
    }
}

// MARK: - Sendable

extension SMFFormatError: Sendable {
}
