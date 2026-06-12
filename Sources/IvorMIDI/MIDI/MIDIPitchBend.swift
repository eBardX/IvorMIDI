// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A MIDI pitch bend value (-8,192–8,191), where 0 is center.
public struct MIDIPitchBend: IntRepresentable {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid MIDI pitch bend value.
    ///
    /// - Parameter intValue:   The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range -8,192–8,191;
    ///             otherwise, `false`.
    public static func isValid(_ intValue: Int) -> Bool {
        (-8_192...8_191).contains(intValue)
    }

    // MARK: Public Initializers

    /// Creates a `MIDIPitchBend` instance with the provided value, or
    /// `nil` if the value is not in the valid range.
    ///
    /// - Parameter intValue:   The pitch bend value. Must be in the range
    ///                         -8,192–8,191.
    public init?(intValue: Int) {
        guard Self.isValid(intValue)
        else { return nil }

        self.intValue = intValue
    }

    // MARK: Public Instance Properties

    /// The pitch bend value.
    public let intValue: Int
}

// MARK: - BytesValueConvertible

extension MIDIPitchBend: BytesValueConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDIPitchBend` instance from the provided array of
    /// bytes, or `nil` if the bytes do not represent a valid value.
    ///
    /// - Parameter bytesValue: The array of bytes. Must contain exactly two
    ///                         bytes encoded LSB-first, each in the range
    ///                         0x00–0x7f.
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 2
        else { return nil }

        self.init(intValue: ((Int(bytesValue[1]) << 7) | Int(bytesValue[0])) - 8_192)
    }

    // MARK: Public Instance Properties

    /// The array of two bytes representing this value in LSB-first order,
    /// or `nil` if the value cannot be encoded.
    public var bytesValue: [UInt8]? {
        let value = intValue + 8_192

        guard let byte0Value = UInt8(exactly: value & 0x7f),
              let byte1Value = UInt8(exactly: value >> 7)
        else { return nil }

        return [byte0Value, byte1Value]
    }
}
