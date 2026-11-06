// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A MIDI non-registered parameter number (NRPN) (0–16,383).
///
/// A non-registered parameter is selected with the non-registered parameter
/// number MSB and LSB controllers (99 and 98), then set with the data entry
/// controllers. Unlike a registered parameter, its number and meaning are
/// defined by each manufacturer. Use
/// ``MIDIChannelMessage/nonRegisteredParameterChange(_:value:on:)`` to build
/// the complete sequence of control change messages.
public struct MIDINonRegisteredParameter {

    // MARK: Public Initializers

    /// Creates a `MIDINonRegisteredParameter` instance with the provided
    /// parameter number, or `nil` if the value is not a valid parameter
    /// number.
    ///
    /// - Parameter uintValue:  The parameter number. Must be in the range
    ///                         0–16,383.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The parameter number.
    public let uintValue: UInt
}

// MARK: -

extension MIDINonRegisteredParameter {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid MIDI non-registered parameter number.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 0–16,383; otherwise,
    ///             `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (0...16_383).contains(uintValue)
    }

    // MARK: Public Instance Properties

    /// The least significant 7 bits of this parameter number, as sent by the
    /// non-registered parameter number LSB controller (98).
    public var lsb: MIDIData1Value {
        MIDIData1Value(clamping: uintValue & 0x7f)
    }

    /// The most significant 7 bits of this parameter number, as sent by the
    /// non-registered parameter number MSB controller (99).
    public var msb: MIDIData1Value {
        MIDIData1Value(clamping: uintValue >> 7)
    }
}

// MARK: - UIntRepresentable

extension MIDINonRegisteredParameter: UIntRepresentable {
}
