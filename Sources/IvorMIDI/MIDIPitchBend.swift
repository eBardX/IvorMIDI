// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A MIDI pitch bend value (-8,192–8,191), where 0 is center.
public struct MIDIPitchBend {

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

// MARK: -

extension MIDIPitchBend {

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
}

// MARK: - IntRepresentable

extension MIDIPitchBend: IntRepresentable {
}

// MARK: - MIDIBytesConvertible

extension MIDIPitchBend: MIDIBytesConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDIPitchBend` instance from its MIDI wire encoding, or
    /// `nil` if the bytes do not encode a valid pitch bend value.
    ///
    /// - Parameter bytesValue: Two 7-bit data bytes, least significant byte
    ///                         first, encoding the pitch bend value offset by
    ///                         8,192 (so that 0x2000 is center).
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 2
        else { return nil }

        self.init(intValue: ((Int(bytesValue[1]) << 7) | Int(bytesValue[0])) - 8_192)
    }

    // MARK: Public Instance Properties

    /// The MIDI wire encoding of this pitch bend value: two 7-bit data
    /// bytes, least significant byte first, encoding the value offset by
    /// 8,192 (so that 0x2000 is center).
    public var bytesValue: [UInt8]? {
        let value = intValue + 8_192

        guard let byte0Value = UInt8(exactly: value & 0x7f),
              let byte1Value = UInt8(exactly: value >> 7)
        else { return nil }

        return [byte0Value, byte1Value]
    }
}
