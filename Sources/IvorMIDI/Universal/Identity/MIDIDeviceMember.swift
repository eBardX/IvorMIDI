// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A device family member code (0–16,383) from an Identity Reply.
///
/// A member code is only meaningful with its ``MIDIDeviceFamily`` and
/// ``MIDIManufacturerID``.
public struct MIDIDeviceMember {

    // MARK: Public Initializers

    /// Creates a `MIDIDeviceMember` instance with the provided member code, or
    /// `nil` if the value is not a valid member code.
    ///
    /// - Parameter uintValue:  The member code. Must be in the range 0–16,383.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    /// Creates a `MIDIDeviceMember` instance from a 14-bit data value.
    ///
    /// - Parameter value:  The member code.
    public init(value: MIDIData2Value) {
        self.uintValue = value.uintValue
    }

    // MARK: Public Instance Properties

    /// The member code.
    public let uintValue: UInt
}

// MARK: -

extension MIDIDeviceMember {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the provided value is a
    /// valid device family member code.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if the value is in the range 0–16,383; otherwise,
    ///             `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        MIDIData2Value.isValid(uintValue)
    }

    // MARK: Public Instance Properties

    /// The member code as a 14-bit data value.
    public var value: MIDIData2Value {
        MIDIData2Value(clamping: uintValue)
    }
}

// MARK: - UIntRepresentable

extension MIDIDeviceMember: UIntRepresentable {
}
