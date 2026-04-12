// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// The number of MIDI ticks per quarter note for metrical time division
/// (0–32,767).
public struct SMFTickRate: UIntRepresentable {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid SMF tick rate.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 0–32,767; otherwise,
    ///             `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (0...32_767).contains(uintValue)
    }

    // MARK: Public Initializers

    /// Creates an `SMFTickRate` instance with the provided tick rate, or
    /// `nil` if the value is not in the valid range.
    ///
    /// - Parameter uintValue:  The tick rate in ticks per quarter note.
    ///                         Must be in the range 0–32,767.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The tick rate in ticks per quarter note.
    public let uintValue: UInt
}

// MARK: - BytesValueConvertible

extension SMFTickRate: BytesValueConvertible {

    // MARK: Public Initializers

    /// Creates an `SMFTickRate` instance from the provided array of bytes,
    /// or `nil` if the bytes do not represent a valid tick rate.
    ///
    /// - Parameter bytesValue: The array of bytes. Must contain exactly two
    ///                         bytes in big-endian order, with the high bit
    ///                         of the first byte clear.
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 2
        else { return nil }

        self.init(uintValue: (UInt(bytesValue[0]) << 8) | UInt(bytesValue[1]))
    }

    // MARK: Public Instance Properties

    /// The array of two bytes representing this tick rate in big-endian
    /// order, or `nil` if the value cannot be encoded.
    public var bytesValue: [UInt8]? {
        guard let byte0Value = UInt8(exactly: uintValue >> 8),
              let byte1Value = UInt8(exactly: uintValue & 0xff)
        else { return nil }

        return [byte0Value, byte1Value]
    }
}

// MARK: - Sendable

extension SMFTickRate: Sendable {
}
