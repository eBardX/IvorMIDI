// © 2026 John Gary Pusey (see LICENSE.md)

/// A MIDI manufacturer ID, which identifies the owner of a manufacturer-specific
/// system exclusive message.
///
/// An ID is either 1 byte (0x01–0x7C) or 3 bytes starting with 0x00. The byte
/// values 0x7D, 0x7E, and 0x7F are not manufacturer IDs: they begin
/// non-commercial and universal messages, which ``MIDISysExEnvelope`` represents
/// with their own cases.
public struct MIDIManufacturerID {

    // MARK: Public Initializers

    /// Creates a `MIDIManufacturerID` instance from its MIDI wire encoding, or
    /// `nil` if the bytes do not encode a valid manufacturer ID.
    ///
    /// - Parameter bytes:  The ID: 1 byte (0x01–0x7C), or 3 bytes starting with
    ///                     0x00, followed by 2 data bytes.
    public init?(bytes: [UInt8]) {
        guard Self._isValid(bytes)
        else { return nil }

        self.bytes = bytes
    }

    // MARK: Public Instance Properties

    /// The MIDI wire encoding of this ID: 1 or 3 bytes.
    public let bytes: [UInt8]

    // MARK: Internal Initializers

    internal init(uncheckedBytes bytes: [UInt8]) {
        self.bytes = bytes
    }
}

// MARK: -

extension MIDIManufacturerID {

    // MARK: Private Type Methods

    private static func _isValid(_ bytes: [UInt8]) -> Bool {
        switch bytes.count {
        case 1:
            (0x01...0x7c).contains(bytes[0])

        case 3:
            bytes[0] == 0x00 && bytes.allSatisfy(\.isMIDIDataByte)

        default:
            false
        }
    }
}

// MARK: - Codable

extension MIDIManufacturerID: Codable {

    // MARK: Public Initializers

    /// Creates a `MIDIManufacturerID` instance by decoding from the provided
    /// decoder.
    ///
    /// - Throws:   A `DecodingError` if decoding fails, or if the decoded bytes
    ///             are not a valid manufacturer ID.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let bytes = try container.decode([UInt8].self)

        guard let value = Self(bytes: bytes)
        else { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath,
                                                                       debugDescription: "Invalid manufacturer ID: \(bytes)")) }

        self = value
    }

    // MARK: Public Instance Methods

    /// Encodes this manufacturer ID into the provided encoder.
    ///
    /// - Throws:   An `EncodingError` if encoding fails.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(bytes)
    }
}

// MARK: - Hashable

extension MIDIManufacturerID: Hashable {
}

// MARK: - Sendable

extension MIDIManufacturerID: Sendable {
}
