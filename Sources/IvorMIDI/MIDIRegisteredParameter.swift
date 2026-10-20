// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A MIDI registered parameter number (RPN) (0–16,383).
///
/// A registered parameter is selected with the registered parameter number
/// MSB and LSB controllers (101 and 100), then set with the data entry
/// controllers. Use
/// ``MIDIChannelMessage/registeredParameterChange(_:value:on:)`` to build the
/// complete sequence of control change messages.
public struct MIDIRegisteredParameter {

    // MARK: Public Initializers

    /// Creates a `MIDIRegisteredParameter` instance with the provided
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

extension MIDIRegisteredParameter {

    // MARK: Public Type Properties

    /// The channel coarse tuning parameter (0, 2).
    public static let coarseTuning = Self(2)

    /// The channel fine tuning parameter (0, 1).
    public static let fineTuning = Self(1)

    /// The modulation depth range parameter (0, 5).
    public static let modulationDepthRange = Self(5)

    /// The null parameter (127, 127), which deselects any registered
    /// parameter so that later data entry has no effect.
    public static let null = Self(16_383)

    /// The pitch bend sensitivity parameter (0, 0).
    public static let pitchBendSensitivity = Self(0)

    /// The tuning bank select parameter (0, 4).
    public static let tuningBankSelect = Self(4)

    /// The tuning program change parameter (0, 3).
    public static let tuningProgramChange = Self(3)

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid MIDI registered parameter number.
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
    /// registered parameter number LSB controller (100).
    public var lsb: MIDIData1Value {
        MIDIData1Value(clamping: uintValue & 0x7f)
    }

    /// The most significant 7 bits of this parameter number, as sent by the
    /// registered parameter number MSB controller (101).
    public var msb: MIDIData1Value {
        MIDIData1Value(clamping: uintValue >> 7)
    }
}

// MARK: - UIntRepresentable

extension MIDIRegisteredParameter: UIntRepresentable {
}
