// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

internal import Foundation

/// A frequency in the MIDI Tuning format (0–2,097,151).
///
/// This is the three-byte frequency data word of the *MIDI Tuning Messages*
/// specification (“Frequency Data Format”). The value counts units of
/// 100/16,384 cents, about 0.0061 cents, up from MIDI note 0: its top 7 bits
/// are the nearest equal-tempered ``semitone`` below the frequency, and its
/// low 14 bits are the ``fraction`` of a semitone above it. The range runs
/// from 8.1758 Hz to about 13,289.66 Hz.
///
/// The highest value, ``noChange``, is reserved. It tells a receiver to leave
/// the tuning of a key as it is, so it is not a frequency.
public struct MIDITuningFrequency {

    // MARK: Public Initializers

    /// Creates a `MIDITuningFrequency` instance with the frequency nearest
    /// to the provided one, or `nil` if it is outside the range of the
    /// format.
    ///
    /// Frequencies are based on A440 in equal temperament, so that 440 Hz
    /// has semitone 69 and fraction 0.
    ///
    /// - Parameter hertz:  The frequency, in hertz. Must be finite and in the
    ///                     range of the format, about 8.1758–13,289.66 Hz.
    public init?(hertz: Double) {
        guard hertz.isFinite,
              hertz > 0
        else { return nil }

        let value = ((69 + 12 * log2(hertz / 440)) * 16_384).rounded()

        guard (0...2_097_150).contains(value)
        else { return nil }

        self.uintValue = UInt(value)
    }

    /// Creates a `MIDITuningFrequency` instance from a semitone and a
    /// fraction of a semitone.
    ///
    /// Semitone 127 with fraction 16,383 makes ``noChange``.
    ///
    /// - Parameter semitone:   The nearest equal-tempered semitone below the
    ///                         frequency, as a MIDI key number.
    /// - Parameter fraction:   The fraction of 100 cents above the semitone,
    ///                         in units of 100/16,384 cents.
    public init(semitone: MIDIData1Value,
                fraction: MIDIData2Value = 0) {
        self.uintValue = (semitone.uintValue << 14) | fraction.uintValue
    }

    /// Creates a `MIDITuningFrequency` instance with the provided value, or
    /// `nil` if the value is not in the valid range.
    ///
    /// - Parameter uintValue:  The value, in units of 100/16,384 cents above
    ///                         MIDI note 0. Must be in the range 0–2,097,151.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The value, in units of 100/16,384 cents above MIDI note 0.
    public let uintValue: UInt
}

// MARK: -

extension MIDITuningFrequency {

    // MARK: Public Type Properties

    /// The reserved value (`7F 7F 7F`) that tells a receiver to make no
    /// change to the tuning of a key.
    public static let noChange = Self(2_097_151)

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid MIDI Tuning frequency value.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 0–2,097,151;
    ///             otherwise, `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (0...2_097_151).contains(uintValue)
    }

    // MARK: Public Instance Properties

    /// The fraction of 100 cents above ``semitone``, in units of 100/16,384
    /// cents.
    public var fraction: MIDIData2Value {
        MIDIData2Value(clamping: uintValue & 0x3fff)
    }

    /// The frequency in hertz, based on A440 in equal temperament, or `nil`
    /// if this is ``noChange``.
    public var hertz: Double? {
        guard self != .noChange
        else { return nil }

        return 440 * pow(2, (Double(uintValue) / 16_384 - 69) / 12)
    }

    /// The nearest equal-tempered semitone below this frequency, as a MIDI
    /// key number.
    public var semitone: MIDIData1Value {
        MIDIData1Value(clamping: uintValue >> 14)
    }
}

// MARK: - MIDIBytesConvertible

extension MIDITuningFrequency: MIDIBytesConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDITuningFrequency` instance from its MIDI wire encoding,
    /// or `nil` if the bytes do not encode a valid value.
    ///
    /// - Parameter bytesValue: Three 7-bit data bytes: the semitone, then the
    ///                         most and least significant 7 bits of the
    ///                         fraction.
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 3,
              bytesValue.allSatisfy(\.isMIDIDataByte)
        else { return nil }

        self.init(uintValue: (UInt(bytesValue[0]) << 14) | (UInt(bytesValue[1]) << 7) | UInt(bytesValue[2]))
    }

    // MARK: Public Instance Properties

    /// The MIDI wire encoding of this value: three 7-bit data bytes, the
    /// semitone, then the most and least significant 7 bits of the fraction.
    public var bytesValue: [UInt8]? {
        guard let byte0Value = UInt8(exactly: uintValue >> 14),
              let byte1Value = UInt8(exactly: (uintValue >> 7) & 0x7f),
              let byte2Value = UInt8(exactly: uintValue & 0x7f)
        else { return nil }

        return [byte0Value, byte1Value, byte2Value]
    }
}

// MARK: - UIntRepresentable

extension MIDITuningFrequency: UIntRepresentable {
}
