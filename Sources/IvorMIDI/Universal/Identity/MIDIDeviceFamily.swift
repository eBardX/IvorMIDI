// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A device family code (0–16,383) from an Identity Reply.
///
/// Each manufacturer assigns its own family codes, so a code is only meaningful
/// with its ``MIDIManufacturerID``.
public struct MIDIDeviceFamily {

    // MARK: Public Initializers

    /// Creates a `MIDIDeviceFamily` instance with the provided family code, or
    /// `nil` if the value is not a valid family code.
    ///
    /// - Parameter uintValue:  The family code. Must be in the range 0–16,383.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    /// Creates a `MIDIDeviceFamily` instance from a 14-bit data value.
    ///
    /// - Parameter value:  The family code.
    public init(value: MIDIData2Value) {
        self.uintValue = value.uintValue
    }

    // MARK: Public Instance Properties

    /// The family code.
    public let uintValue: UInt
}

// MARK: -

extension MIDIDeviceFamily {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid device family code.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 0–16,383; otherwise,
    ///             `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        MIDIData2Value.isValid(uintValue)
    }

    // MARK: Public Instance Properties

    /// The family code as a 14-bit data value.
    public var value: MIDIData2Value {
        MIDIData2Value(clamping: uintValue)
    }
}

// MARK: - UIntRepresentable

extension MIDIDeviceFamily: UIntRepresentable {
}
