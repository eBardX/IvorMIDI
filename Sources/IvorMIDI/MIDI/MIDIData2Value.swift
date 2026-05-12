// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A 14-bit MIDI data value (0–16,383).
public struct MIDIData2Value: UIntRepresentable {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid 14-bit MIDI data value.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 0–16,383; otherwise,
    ///             `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (0...16_383).contains(uintValue)
    }

    // MARK: Public Initializers

    /// Creates a `MIDIData2Value` instance with the provided value, or
    /// `nil` if the value is not in the valid range.
    ///
    /// - Parameter uintValue:  The data value. Must be in the range
    ///                         0–16,383.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The data value.
    public let uintValue: UInt
}

// MARK: - BytesValueConvertible

extension MIDIData2Value: BytesValueConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDIData2Value` instance from the provided array of
    /// bytes, or `nil` if the bytes do not represent a valid value.
    ///
    /// - Parameter bytesValue: The array of bytes. Must contain exactly two
    ///                         bytes encoded LSB-first, each in the range
    ///                         0x00–0x7f.
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 2
        else { return nil }

        self.init(uintValue: (UInt(bytesValue[1]) << 7) | UInt(bytesValue[0]))
    }

    // MARK: Public Instance Properties

    /// The array of two bytes representing this value in LSB-first order,
    /// or `nil` if the value cannot be encoded.
    public var bytesValue: [UInt8]? {
        guard let byte0Value = UInt8(exactly: uintValue & 0x7f),
              let byte1Value = UInt8(exactly: uintValue >> 7)
        else { return nil }

        return [byte0Value, byte1Value]
    }
}

// MARK: - Sendable

extension MIDIData2Value: Sendable {
}
