// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A MIDI channel number (1–16).
public struct MIDIChannel: UIntRepresentable {

    // MARK: Public Initializers

    /// Creates a `MIDIChannel` instance with the provided channel number,
    /// or `nil` if the value is not a valid channel number.
    ///
    /// - Parameter uintValue:  The channel number. Must be in the range
    ///                         1–16.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The channel number.
    public let uintValue: UInt
}

// MARK: -

extension MIDIChannel {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid MIDI channel number.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 1–16; otherwise,
    ///             `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (1...16).contains(uintValue)
    }
}

// MARK: - BytesValueConvertible

extension MIDIChannel: BytesValueConvertible {

    // MARK: Internal Initializers

    internal init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 1
        else { return nil }

        self.init(uintValue: UInt(bytesValue[0]) + 1)
    }

    // MARK: Internal Instance Properties

    internal var bytesValue: [UInt8]? {
        guard let byte0Value = UInt8(exactly: uintValue - 1)
        else { return nil }

        return [byte0Value]
    }
}
