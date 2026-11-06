// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A MIDI program number (1–128).
///
/// Program numbers are 1-based, as the General MIDI specification and most
/// instruments number them; a program change message encodes them as a
/// zero-based data byte (0–127).
public struct MIDIProgram {

    // MARK: Public Initializers

    /// Creates a `MIDIProgram` instance with the provided program number,
    /// clamped to the valid range.
    ///
    /// - Parameter value:  The program number. A value below 1 becomes 1; a
    ///                     value above 128 becomes 128.
    public init(clamping value: some BinaryInteger) {
        self.uintValue = UInt(value.clamped(to: 1...128))
    }

    /// Creates a `MIDIProgram` instance with the provided program number, or
    /// `nil` if the value is not a valid program number.
    ///
    /// - Parameter uintValue:  The program number. Must be in the range
    ///                         1–128.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The program number.
    public let uintValue: UInt
}

// MARK: -

extension MIDIProgram {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid MIDI program number.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 1–128; otherwise,
    ///             `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (1...128).contains(uintValue)
    }
}

// MARK: - MIDIBytesConvertible

extension MIDIProgram: MIDIBytesConvertible {

    // MARK: Public Initializers

    /// Creates a `MIDIProgram` instance from its MIDI wire encoding, or `nil`
    /// if the bytes do not encode a valid program number.
    ///
    /// - Parameter bytesValue: A single byte holding the zero-based program
    ///                         number (0–127).
    public init?(bytesValue: [UInt8]) {
        guard bytesValue.count == 1
        else { return nil }

        self.init(uintValue: UInt(bytesValue[0]) + 1)
    }

    // MARK: Public Instance Properties

    /// The MIDI wire encoding of this program number: a single byte holding
    /// the zero-based program number (0–127).
    public var bytesValue: [UInt8]? {
        guard let byte0Value = UInt8(exactly: uintValue - 1)
        else { return nil }

        return [byte0Value]
    }
}

// MARK: - UIntRepresentable

extension MIDIProgram: UIntRepresentable {
}
