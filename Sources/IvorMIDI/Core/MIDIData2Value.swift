// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A 14-bit MIDI data value (0–16,383).
public struct MIDIData2Value {

    // MARK: Public Initializers

    /// Creates a `MIDIData2Value` instance with the provided value, clamped
    /// to the valid range.
    ///
    /// - Parameter value:  The data value. A value below 0 becomes 0; a value
    ///                     above 16,383 becomes 16,383.
    public init(clamping value: some BinaryInteger) {
        self.uintValue = UInt(value.clamped(to: 0...16_383))
    }

    /// Creates a `MIDIData2Value` instance from its most and least
    /// significant 7 bits.
    ///
    /// - Parameter msb:    The most significant 7 bits.
    /// - Parameter lsb:    The least significant 7 bits.
    public init(msb: MIDIData1Value,
                lsb: MIDIData1Value) {
        self.uintValue = (msb.uintValue << 7) | lsb.uintValue
    }

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

// MARK: -

extension MIDIData2Value {

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

    // MARK: Public Instance Properties

    /// The least significant 7 bits of this data value, as sent by the LSB
    /// half of a pair of controllers such as data entry or bank select.
    public var lsb: MIDIData1Value {
        MIDIData1Value(clamping: uintValue & 0x7f)
    }

    /// The most significant 7 bits of this data value, as sent by the MSB
    /// half of a pair of controllers such as data entry or bank select.
    public var msb: MIDIData1Value {
        MIDIData1Value(clamping: uintValue >> 7)
    }
}

// MARK: - MIDIBytesConvertible

extension MIDIData2Value: MIDIBytesConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDIData2Value` instance from its MIDI wire encoding, or
    /// `nil` if the bytes do not encode a valid data value.
    ///
    /// - Parameter bytesValue: Two 7-bit data bytes, least significant byte
    ///                         first.
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 2
        else { return nil }

        self.init(uintValue: (UInt(bytesValue[1]) << 7) | UInt(bytesValue[0]))
    }

    // MARK: Public Instance Properties

    /// The MIDI wire encoding of this data value: two 7-bit data bytes,
    /// least significant byte first.
    public var bytesValue: [UInt8]? {
        guard let byte0Value = UInt8(exactly: uintValue & 0x7f),
              let byte1Value = UInt8(exactly: uintValue >> 7)
        else { return nil }

        return [byte0Value, byte1Value]
    }
}

// MARK: - UIntRepresentable

extension MIDIData2Value: UIntRepresentable {
}
