// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A MIDI bank number (0–16,383).
///
/// A bank is selected with the bank select MSB and LSB controllers (0 and
/// 32), then a program change picks a program in it. A sound bank’s tools
/// usually show the bank number, while a synthesizer’s manual usually lists
/// the MSB and LSB: bank 15,489 is MSB 121, LSB 1.
public struct MIDIBank {

    // MARK: Public Initializers

    /// Creates a `MIDIBank` instance from its bank select MSB and LSB.
    ///
    /// - Parameter msb:    The most significant 7 bits, as sent by the bank
    ///                     select MSB controller (0).
    /// - Parameter lsb:    The least significant 7 bits, as sent by the bank
    ///                     select LSB controller (32).
    public init(msb: MIDIData1Value,
                lsb: MIDIData1Value) {
        self.uintValue = (msb.uintValue << 7) | lsb.uintValue
    }

    /// Creates a `MIDIBank` instance with the provided bank number, or `nil`
    /// if the value is not a valid bank number.
    ///
    /// - Parameter uintValue:  The bank number. Must be in the range
    ///                         0–16,383.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The bank number.
    public let uintValue: UInt
}

// MARK: -

extension MIDIBank {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid MIDI bank number.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 0–16,383; otherwise,
    ///             `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (0...16_383).contains(uintValue)
    }

    // MARK: Public Instance Properties

    /// The least significant 7 bits of this bank number, as sent by the bank
    /// select LSB controller (32).
    public var lsb: MIDIData1Value {
        MIDIData1Value(clamping: uintValue & 0x7f)
    }

    /// The most significant 7 bits of this bank number, as sent by the bank
    /// select MSB controller (0).
    public var msb: MIDIData1Value {
        MIDIData1Value(clamping: uintValue >> 7)
    }
}

// MARK: - UIntRepresentable

extension MIDIBank: UIntRepresentable {
}
